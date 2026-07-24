//
//  Label.swift
//  SwiftUICore
//
//  A title paired with an icon. Emitted as its own node (icon child, then title
//  child) rather than desugared to an HStack, so `labelStyle` can drop either
//  half — which it does through the same inherited-CompositionLocal mechanism the
//  control styles use.
//

public struct Label<Title: View, Icon: View>: View {

    internal let title: Title
    internal let icon: Icon

    public init(@ViewBuilder title: () -> Title, @ViewBuilder icon: () -> Icon) {
        self.title = title()
        self.icon = icon()
    }

    public typealias Body = Never
}

public extension Label where Title == Text, Icon == Image {
    init<S: StringProtocol>(_ title: S, systemImage name: String) {
        self.init(title: { Text(title) }, icon: { Image(systemName: name) })
    }

    init<S: StringProtocol>(_ title: S, image name: String) {
        self.init(title: { Text(title) }, icon: { Image(name) })
    }
}

extension Label: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        // icon first, title second — the interpreter relies on that order to
        // show or hide each half per the label style
        let iconNode = Evaluator.resolve(icon, context.descending("icon"))
        let titleNode = Evaluator.resolve(title, context.descending("title"))
        return RenderNode(type: "Label", id: context.path, children: [iconNode, titleNode])
    }
}

// MARK: - Style

/// The built-in label styles. Like the control styles, this is the spelling
/// only — the `LabelStyle` protocol for custom layouts isn't modeled.
public struct _LabelStyle: Sendable {
    internal let kind: String
    public static let automatic = _LabelStyle(kind: "automatic")
    public static let titleAndIcon = _LabelStyle(kind: "titleAndIcon")
    public static let titleOnly = _LabelStyle(kind: "titleOnly")
    public static let iconOnly = _LabelStyle(kind: "iconOnly")
}

public struct _LabelStyleModifier: RenderModifier {
    let style: _LabelStyle
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "labelStyle", args: ["style": .string(style.kind)])
    }
}

public extension View {
    func labelStyle(_ style: _LabelStyle) -> ModifiedContent<Self, _LabelStyleModifier> {
        modifier(_LabelStyleModifier(style: style))
    }
}
