//
//  GeometryReader.swift
//  AndroidSwiftUICore
//
//  Size feedback from layout back into Swift — the one place the data flows
//  backwards. Swift resolves a tree *before* Compose lays it out, so the size
//  can't be known on the first pass: the interpreter measures, reports the size
//  through a callback, and the resulting store update re-evaluates with the real
//  numbers. Rendering a GeometryReader therefore settles over two passes.
//
//  The reported size comes from the *constraints the parent offers*, never from
//  the content, so measuring can't feed back into itself. The store also drops
//  a report that matches what it already holds, so a steady layout stops.
//

import Foundation

/// The geometry of the space a `GeometryReader` was offered.
public struct GeometryProxy: Sendable {
    public let size: CGSize
}

/// Holds the last size the interpreter reported for one GeometryReader,
/// persisted at its identity path so it survives re-evaluation.
internal final class GeometrySizeStore {

    private(set) var size = CGSize(width: 0, height: 0)
    var onChange: (() -> Void)?

    /// Records a `"<width>,<height>"` report, re-evaluating only on a change.
    func update(from payload: String) {
        let parts = payload.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 2 else { return }
        guard parts[0] != size.width || parts[1] != size.height else { return }
        size = CGSize(width: parts[0], height: parts[1])
        onChange?()
    }
}

public struct GeometryReader<Content: View>: View {

    internal let content: (GeometryProxy) -> Content

    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    public typealias Body = Never
}

extension GeometryReader: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        let store = context.storage.persistentObject(at: context.path + ".geometry") {
            GeometrySizeStore()
        }
        store.onChange = context.storage.onChange
        let id = context.callbacks.register(.string { [store] payload in
            store.update(from: payload)
        })
        // first pass resolves against .zero; the report brings the real size
        let proxy = GeometryProxy(size: store.size)
        return RenderNode(
            type: "GeometryReader",
            id: context.path,
            props: ["onSize": .int(Int(id))],
            children: Evaluator.resolveChildren(content(proxy), context.descending("content"))
        )
    }
}
