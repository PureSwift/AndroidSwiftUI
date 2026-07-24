//
//  ControlStyles.swift
//  SwiftUICore
//
//  Control styles. Unlike a per-node modifier, a style applies to every matching
//  control in the subtree — `VStack { … }.buttonStyle(.bordered)` styles all the
//  buttons inside it — so the interpreter carries these down as environment
//  values rather than reading them off the styled node.
//
//  These are the built-in style spellings only; the `ButtonStyle` /
//  `ToggleStyle` / … protocols for writing custom styles aren't modeled.
//

/// A style value shared by every control-style modifier: an opaque kind string
/// the interpreter maps to a platform presentation.
public struct _ControlStyle: Sendable, Equatable {
    internal let kind: String
    internal init(_ kind: String) { self.kind = kind }
}

public extension _ControlStyle {
    // button
    static let automatic = _ControlStyle("automatic")
    static let bordered = _ControlStyle("bordered")
    static let borderedProminent = _ControlStyle("borderedProminent")
    static let borderless = _ControlStyle("borderless")
    static let plain = _ControlStyle("plain")
    // picker
    static let segmented = _ControlStyle("segmented")
    static let menu = _ControlStyle("menu")
    static let inline = _ControlStyle("inline")
    // toggle
    static let `switch` = _ControlStyle("switch")
    static let checkbox = _ControlStyle("checkbox")
    static let button = _ControlStyle("button")
    // text field
    static let roundedBorder = _ControlStyle("roundedBorder")
}

/// Emits one style kind; the `kind` names which control it governs, so styles
/// for different controls compose instead of overwriting each other.
public struct _ControlStyleModifier: RenderModifier {
    let control: String
    let style: _ControlStyle
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: control, args: ["style": .string(style.kind)])
    }
}

public extension View {

    func buttonStyle(_ style: _ControlStyle) -> ModifiedContent<Self, _ControlStyleModifier> {
        modifier(_ControlStyleModifier(control: "buttonStyle", style: style))
    }

    func pickerStyle(_ style: _ControlStyle) -> ModifiedContent<Self, _ControlStyleModifier> {
        modifier(_ControlStyleModifier(control: "pickerStyle", style: style))
    }

    func toggleStyle(_ style: _ControlStyle) -> ModifiedContent<Self, _ControlStyleModifier> {
        modifier(_ControlStyleModifier(control: "toggleStyle", style: style))
    }

    func textFieldStyle(_ style: _ControlStyle) -> ModifiedContent<Self, _ControlStyleModifier> {
        modifier(_ControlStyleModifier(control: "textFieldStyle", style: style))
    }
}
