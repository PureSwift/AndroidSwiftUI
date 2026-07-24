//
//  KeyboardModifiers.swift
//  AndroidSwiftUICore
//
//  Soft-keyboard configuration for text entry. A field reads these off its own
//  modifier list (like `.focused`): the type chooses the key layout, the submit
//  label names the action key, and `onSubmit` fires when that key is pressed.
//

/// The soft keyboard a text field requests. Named to match SwiftUI's
/// `UIKeyboardType` so call sites port unchanged.
public enum UIKeyboardType: String, Sendable {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
}

/// The label on the keyboard's action key.
public struct SubmitLabel: Sendable {
    internal let kind: String
    public static let done = SubmitLabel(kind: "done")
    public static let go = SubmitLabel(kind: "go")
    public static let send = SubmitLabel(kind: "send")
    public static let join = SubmitLabel(kind: "join")
    public static let route = SubmitLabel(kind: "route")
    public static let search = SubmitLabel(kind: "search")
    public static let `return` = SubmitLabel(kind: "return")
    public static let next = SubmitLabel(kind: "next")
    public static let `continue` = SubmitLabel(kind: "continue")
}

public struct _KeyboardTypeModifier: RenderModifier {
    let type: UIKeyboardType
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "keyboardType", args: ["type": .string(type.rawValue)])
    }
}

public struct _SubmitLabelModifier: RenderModifier {
    let label: SubmitLabel
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "submitLabel", args: ["label": .string(label.kind)])
    }
}

public struct _OnSubmitModifier: RenderModifier, _CallbackModifier {
    let action: () -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "onSubmit") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        return ModifierNode(kind: "onSubmit", args: ["action": .int(Int(id))])
    }
}

public extension View {

    func keyboardType(_ type: UIKeyboardType) -> ModifiedContent<Self, _KeyboardTypeModifier> {
        modifier(_KeyboardTypeModifier(type: type))
    }

    func submitLabel(_ label: SubmitLabel) -> ModifiedContent<Self, _SubmitLabelModifier> {
        modifier(_SubmitLabelModifier(label: label))
    }

    /// Runs `action` when the user submits the text field (presses the keyboard
    /// action key).
    func onSubmit(perform action: @escaping () -> Void) -> ModifiedContent<Self, _OnSubmitModifier> {
        modifier(_OnSubmitModifier(action: action))
    }
}
