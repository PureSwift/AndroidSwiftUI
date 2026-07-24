//
//  Popover.swift
//  SwiftUICore
//
//  A small piece of content floated next to a view while `isPresented` is true.
//  Anchored to a specific view (not screen-level like a sheet), so it emits a
//  wrapper node — `anchorCount` leading children are the anchor, the rest are the
//  popover body — with the binding's state and a dismiss callback. Dismissing
//  anywhere off the bubble writes the flag back.
//

public struct _PopoverView<Content: View, Popover: View>: View {
    internal let isPresented: Binding<Bool>
    internal let content: Content
    internal let popover: Popover
    public typealias Body = Never
}

extension _PopoverView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let anchorNodes = Evaluator.resolveChildren(content, context.descending("content"))
        let binding = isPresented

        var props: [String: PropValue] = [
            "anchorCount": .int(anchorNodes.count),
            "isPresented": .bool(binding.wrappedValue),
        ]
        // resolve the body only while shown; a dismiss callback lets the bubble
        // write the flag back on an outside tap
        var bodyNodes: [RenderNode] = []
        if binding.wrappedValue {
            let dismissID = context.callbacks.register(.void { binding.wrappedValue = false })
            props["onDismiss"] = .int(Int(dismissID))
            var popoverContext = context.descending("popover")
            popoverContext.environment.values.dismiss = DismissAction { binding.wrappedValue = false }
            bodyNodes = Evaluator.resolveChildren(popover, popoverContext)
        }
        return RenderNode(
            type: "Popover",
            id: context.path,
            props: props,
            children: anchorNodes + bodyNodes
        )
    }
}

public extension View {
    func popover<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> C
    ) -> _PopoverView<Self, C> {
        _PopoverView(isPresented: isPresented, content: self, popover: content())
    }
}
