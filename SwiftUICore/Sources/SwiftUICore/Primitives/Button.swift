//
//  Button.swift
//  SwiftUICore
//

/// A control that performs an action when triggered.
public struct Button<Label: View>: View {

    internal let action: () -> Void
    internal let label: Label

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public typealias Body = Never
}

public extension Button where Label == Text {
    init<S: StringProtocol>(_ title: S, action: @escaping () -> Void) {
        self.init(action: action) { Text(title) }
    }
}

extension Button: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let callbackID = context.callbacks.register(.void(action))
        return RenderNode(
            type: "Button",
            id: context.path,
            props: ["onTap": .int(Int(callbackID))],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}
