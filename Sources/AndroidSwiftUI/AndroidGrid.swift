//
//  AndroidGrid.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

extension LazyVGrid: AndroidPrimitive {

    var renderedBody: AnyView {
        let proxy = _LazyVGridProxy(self)
        return AnyView(AndroidGridView(
            tracks: proxy.columns,
            spacing: proxy.spacing,
            vertical: true,
            cells: gridCells(in: AnyView(proxy.content))
        ))
    }
}

extension LazyHGrid: AndroidPrimitive {

    var renderedBody: AnyView {
        let proxy = _LazyHGridProxy(self)
        return AnyView(AndroidGridView(
            tracks: proxy.rows,
            spacing: proxy.spacing,
            vertical: false,
            cells: gridCells(in: AnyView(proxy.content))
        ))
    }
}

/// Recursively flattens group views and identified views to the leaf cells they contain,
/// the same way the picker recovers its rows.
///
/// Modified content is a leaf, not a group: it technically conforms to `GroupView` (with
/// its bare content as the only child), so descending into it would silently strip every
/// modifier off the cell.
private func gridCells(in view: AnyView) -> [AnyView] {
    if view.view is _AnyModifiedContent {
        return [view]
    }
    if let identified = view.view as? _AnyIDView {
        return gridCells(in: identified.anyContent)
    }
    guard let group = view.view as? GroupView else { return [view] }
    return group.children.flatMap { gridCells(in: $0) }
}

/// Native Compose-backed lazy grid.
struct AndroidGridView {

    let tracks: [GridItem]

    let spacing: CGFloat

    let vertical: Bool

    let cells: [AnyView]
}

extension AndroidGridView: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> ComposeGridView {
        let adapter = GridViewAdapter(swiftObject: SwiftObject(GridViewAdapter.Context(cells: cells)))
        // a single adaptive item fits as many tracks as possible; any other configuration
        // lays out one track per item, matching SwiftUI's common usage
        let trackCount: Int32
        let minItemSize: Float
        if tracks.count == 1, case let .adaptive(minimum, _) = tracks[0].size {
            trackCount = 0
            minItemSize = Float(minimum)
        } else {
            trackCount = Int32(max(tracks.count, 1))
            minItemSize = 0
        }
        return ComposeGridView(
            context.androidContext,
            adapter,
            trackCount,
            minItemSize,
            Float(spacing),
            vertical
        )
    }

    func updateAndroidView(_ view: ComposeGridView, context: Self.Context) {
        guard let adapter = view.getAdapter() else { return }
        adapter.context = GridViewAdapter.Context(cells: cells)
        view.refresh()
    }
}
