//
//  DisclosureGroup.swift
//  AndroidSwiftUICore
//
//  A label that expands to reveal its content. Expansion can be left to the
//  interpreter (it remembers the open/closed state) or driven by a binding —
//  when bound, the header's tap round-trips through a callback so Swift stays
//  the source of truth, exactly like a Toggle.
//

public struct DisclosureGroup<Label: View, Content: View>: View {

    internal let label: Label
    internal let content: Content
    internal let isExpanded: Binding<Bool>?

    public init(
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.isExpanded = isExpanded
        self.content = content()
        self.label = label()
    }

    public typealias Body = Never
}

public extension DisclosureGroup where Label == Text {

    init<S: StringProtocol>(_ title: S, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(title) }
    }

    init<S: StringProtocol>(
        _ title: S,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(isExpanded: isExpanded, content: content) { Text(title) }
    }
}

extension DisclosureGroup: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        // label first, then content; `labelCount` tells the interpreter where the
        // header ends and the body begins
        let labelNodes = Evaluator.resolveChildren(label, context.descending("label"))
        let contentNodes = Evaluator.resolveChildren(content, context.descending("content"))

        var props: [String: PropValue] = ["labelCount": .int(labelNodes.count)]
        if let isExpanded {
            props["isExpanded"] = .bool(isExpanded.wrappedValue)
            let binding = isExpanded
            let id = context.callbacks.register(.bool { binding.wrappedValue = $0 })
            props["onToggle"] = .int(Int(id))
        }
        return RenderNode(
            type: "DisclosureGroup",
            id: context.path,
            props: props,
            children: labelNodes + contentNodes
        )
    }
}
