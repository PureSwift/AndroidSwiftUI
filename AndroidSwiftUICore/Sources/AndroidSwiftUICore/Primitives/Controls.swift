//
//  Controls.swift
//  AndroidSwiftUICore
//

/// A control that toggles a boolean.
public struct Toggle<Label: View>: View {

    internal let isOn: Binding<Bool>
    internal let label: Label

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.label = label()
    }

    public typealias Body = Never
}

public extension Toggle where Label == Text {
    init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>) {
        self.init(isOn: isOn) { Text(title) }
    }
}

extension Toggle: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = isOn
        let callbackID = context.callbacks.register(.bool { binding.wrappedValue = $0 })
        return RenderNode(
            type: "Toggle",
            id: context.path,
            props: ["isOn": .bool(isOn.wrappedValue), "onChange": .int(Int(callbackID))],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}

/// Flexible empty space along a stack's axis.
public struct Spacer: View {
    internal let minLength: Double?
    public init(minLength: Double? = nil) { self.minLength = minLength }
    public typealias Body = Never
}

extension Spacer: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = [:]
        if let minLength { props["minLength"] = .double(minLength) }
        return RenderNode(type: "Spacer", id: context.path, props: props)
    }
}

/// A visual divider line.
public struct Divider: View {
    public init() {}
    public typealias Body = Never
}

extension Divider: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(type: "Divider", id: context.path)
    }
}
