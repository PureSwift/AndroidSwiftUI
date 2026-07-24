//
//  DatePicker.swift
//  SwiftUICore
//
//  A control for choosing a calendar date. The selection round-trips the
//  bridge as milliseconds since the Unix epoch — Compose's Material3
//  DatePickerState currency, and a trivial conversion from Foundation's Date.
//

import Foundation

public struct DatePicker<Label: View>: View {

    internal let label: Label
    internal let selection: Binding<Date>

    public init(selection: Binding<Date>, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.selection = selection
    }

    public typealias Body = Never
}

public extension DatePicker where Label == Text {
    init<S: StringProtocol>(_ title: S, selection: Binding<Date>) {
        self.init(selection: selection) { Text(title) }
    }
}

extension DatePicker: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = selection
        let callbackID = context.callbacks.register(.double { millis in
            binding.wrappedValue = Date(timeIntervalSince1970: millis / 1000)
        })
        return RenderNode(
            type: "DatePicker",
            id: context.path,
            props: [
                "millis": .double(selection.wrappedValue.timeIntervalSince1970 * 1000),
                "onChange": .int(Int(callbackID)),
            ],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}
