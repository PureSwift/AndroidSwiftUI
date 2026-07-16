//
//  AndroidScrollView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension ScrollView: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidScrollContainer(axes: axes, content: content))
    }
}

/// Native container for `ScrollView`. Android's `ScrollView`/`HorizontalScrollView` accept only a
/// single direct child, so `content` (which may expand to multiple top-level views, e.g. `ScrollView { A; B }`)
/// is wrapped in a single inner `AndroidLinearLayout`.
struct AndroidScrollContainer<Content: View> {

    let axes: Axis.Set

    let content: Content
}

extension AndroidScrollContainer: ParentView {

    var children: [AnyView] {
        let orientation: AndroidLinearLayout.Orientation = axes.contains(.horizontal) ? .horizontal : .vertical
        return [AnyView(AndroidLinearLayout(orientation: orientation, gravity: .noGravity) { content })]
    }
}

extension AndroidScrollContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidView.View {
        if axes.contains(.horizontal) {
            return AndroidWidget.HorizontalScrollView(context.androidContext)
        } else {
            return AndroidWidget.ScrollView(context.androidContext)
        }
    }

    func updateAndroidView(_ view: AndroidView.View, context: Self.Context) {

    }
}
