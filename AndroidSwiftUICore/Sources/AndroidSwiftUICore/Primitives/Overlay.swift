//
//  Overlay.swift
//  AndroidSwiftUICore
//
//  `.overlay { … }` layers content over a view, sized to the base. Emitted as an
//  Overlay node whose first child is the base and second is the overlay; the
//  interpreter stacks the overlay at the base's size with the given alignment.
//

public struct _OverlayView<Base: View, Overlay: View>: View {
    internal let base: Base
    internal let overlay: Overlay
    internal let alignment: Alignment
    public typealias Body = Never
}

extension _OverlayView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "Overlay",
            id: context.path,
            props: [
                "horizontal": .string(alignment.horizontal.rawValue),
                "vertical": .string(alignment.vertical.rawValue),
            ],
            children: [
                Evaluator.resolve(base, context.descending("base")),
                Evaluator.resolve(overlay, context.descending("overlay")),
            ]
        )
    }
}

public extension View {
    func overlay<V: View>(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> V
    ) -> _OverlayView<Self, V> {
        _OverlayView(base: self, overlay: content(), alignment: alignment)
    }
}
