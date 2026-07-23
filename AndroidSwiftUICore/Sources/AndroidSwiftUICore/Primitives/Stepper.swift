//
//  Stepper.swift
//  AndroidSwiftUICore
//
//  A control that increments or decrements a value. The core registers the two
//  edge actions as callbacks; the interpreter renders a label plus − / + buttons.
//

public struct Stepper<Label: View>: View {

    internal let label: Label
    internal let onIncrement: () -> Void
    internal let onDecrement: () -> Void

    public init(
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public typealias Body = Never
}

public extension Stepper where Label == Text {

    init<S: StringProtocol, V: Strideable>(
        _ title: S,
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1
    ) {
        self.init(
            onIncrement: {
                let next = value.wrappedValue.advanced(by: step)
                if next <= bounds.upperBound { value.wrappedValue = next }
            },
            onDecrement: {
                let previous = value.wrappedValue.advanced(by: -step)
                if previous >= bounds.lowerBound { value.wrappedValue = previous }
            },
            label: { Text(title) }
        )
    }

    init<S: StringProtocol, V: Strideable>(
        _ title: S,
        value: Binding<V>,
        step: V.Stride = 1
    ) {
        self.init(
            onIncrement: { value.wrappedValue = value.wrappedValue.advanced(by: step) },
            onDecrement: { value.wrappedValue = value.wrappedValue.advanced(by: -step) },
            label: { Text(title) }
        )
    }
}

extension Stepper: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let incrementID = context.callbacks.register(.void(onIncrement))
        let decrementID = context.callbacks.register(.void(onDecrement))
        return RenderNode(
            type: "Stepper",
            id: context.path,
            props: [
                "onIncrement": .int(Int(incrementID)),
                "onDecrement": .int(Int(decrementID)),
            ],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}
