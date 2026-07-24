//
//  Accessibility.swift
//  SwiftUICore
//
//  Accessibility describes a view to assistive technology rather than changing
//  how it looks, so every one of these folds into Compose semantics: a label
//  becomes the content description, a value becomes the state description,
//  traits become a role, and hiding clears the subtree's semantics outright.
//

/// Roles that change how assistive technology announces a view.
public struct AccessibilityTraits: OptionSet, Sendable {

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let isButton = AccessibilityTraits(rawValue: 1 << 0)
    public static let isHeader = AccessibilityTraits(rawValue: 1 << 1)
    public static let isSelected = AccessibilityTraits(rawValue: 1 << 2)
    public static let isImage = AccessibilityTraits(rawValue: 1 << 3)

    /// The names the interpreter maps to Compose semantics.
    internal var names: [String] {
        var names: [String] = []
        if contains(.isButton) { names.append("button") }
        if contains(.isHeader) { names.append("header") }
        if contains(.isSelected) { names.append("selected") }
        if contains(.isImage) { names.append("image") }
        return names
    }
}

public struct _AccessibilityModifier: RenderModifier {
    let kind: String
    let args: [String: PropValue]
    public var _modifierNode: ModifierNode { ModifierNode(kind: kind, args: args) }
}

public extension View {

    /// The description assistive technology reads for this view.
    func accessibilityLabel<S: StringProtocol>(_ label: S) -> ModifiedContent<Self, _AccessibilityModifier> {
        modifier(_AccessibilityModifier(kind: "accessibilityLabel", args: ["text": .string(String(label))]))
    }

    /// The view's current value, announced after its label.
    func accessibilityValue<S: StringProtocol>(_ value: S) -> ModifiedContent<Self, _AccessibilityModifier> {
        modifier(_AccessibilityModifier(kind: "accessibilityValue", args: ["text": .string(String(value))]))
    }

    /// Removes the view, and everything inside it, from the accessibility tree.
    func accessibilityHidden(_ hidden: Bool) -> ModifiedContent<Self, _AccessibilityModifier> {
        modifier(_AccessibilityModifier(kind: "accessibilityHidden", args: ["value": .bool(hidden)]))
    }

    func accessibilityAddTraits(_ traits: AccessibilityTraits) -> ModifiedContent<Self, _AccessibilityModifier> {
        modifier(_AccessibilityModifier(
            kind: "accessibilityAddTraits",
            args: ["traits": .array(traits.names.map { .string($0) })]
        ))
    }

    /// A stable handle for UI tests. Never announced.
    func accessibilityIdentifier<S: StringProtocol>(_ identifier: S) -> ModifiedContent<Self, _AccessibilityModifier> {
        modifier(_AccessibilityModifier(kind: "accessibilityIdentifier", args: ["id": .string(String(identifier))]))
    }

}
