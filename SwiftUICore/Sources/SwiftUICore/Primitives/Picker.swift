//
//  Picker.swift
//  SwiftUICore
//

/// Associates a selection value with a picker row.
public struct _TagModifier: RenderModifier {
    let value: String
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "tag", args: ["value": .string(value)])
    }
}

public extension View {
    func tag<V: Hashable>(_ value: V) -> ModifiedContent<Self, _TagModifier> {
        modifier(_TagModifier(value: identityString(value)))
    }
}

/// A control for selecting one of several tagged options.
///
/// Selection values round-trip the bridge as strings, so they must be
/// `LosslessStringConvertible` (String and Int both are).
public struct Picker<SelectionValue: Hashable & LosslessStringConvertible, Content: View>: View {

    internal let title: String
    internal let selection: Binding<SelectionValue>
    internal let content: Content

    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = String(title)
        self.selection = selection
        self.content = content()
    }

    public typealias Body = Never
}

extension Picker: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = selection
        let callbackID = context.callbacks.register(.string { raw in
            guard let value = SelectionValue(raw) else { return }
            binding.wrappedValue = value
        })
        return RenderNode(
            type: "Picker",
            id: context.path,
            props: [
                "title": .string(title),
                "selection": .string(identityString(selection.wrappedValue)),
                "onChange": .int(Int(callbackID)),
            ],
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}
