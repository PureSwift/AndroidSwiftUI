//
//  Menu.swift
//  SwiftUICore
//
//  A button that presents a dropdown of actions. The content's buttons become
//  the menu items; the interpreter shows them in a Compose DropdownMenu.
//

public struct Menu<Label: View, Content: View>: View {

    internal let label: Label
    internal let content: Content

    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.content = content()
        self.label = label()
    }

    public typealias Body = Never
}

public extension Menu where Label == Text {
    init<S: StringProtocol>(_ title: S, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(title) }
    }
}

extension Menu: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let labelNodes = Evaluator.resolveChildren(label, context.descending("label"))
        let title = labelNodes.lazy.compactMap(firstTextString).first ?? ""
        return RenderNode(
            type: "Menu",
            id: context.path,
            props: ["label": .string(title)],
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

/// The first Text content found in a node subtree, if any.
internal func firstTextString(_ node: RenderNode) -> String? {
    if node.type == "Text", case .string(let text)? = node.props["text"] { return text }
    for child in node.children {
        if let text = firstTextString(child) { return text }
    }
    return nil
}
