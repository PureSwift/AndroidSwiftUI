//
//  TextModifiers.swift
//  SwiftUICore
//
//  Text-styling modifiers. Unlike layout modifiers (padding, background…) that
//  fold into the Compose `Modifier` chain, these describe attributes of the
//  `Text` composable itself; the interpreter reads their kinds off a Text
//  node's modifier chain and applies them as `Text(...)` parameters.
//

// MARK: - Font

/// A font: either a named text style (resolved to a size by the interpreter)
/// or an explicit system size, with an optional weight.
public struct Font: Equatable, Sendable {

    internal var style: String?
    internal var size: Double?
    internal var weight: Weight?

    internal init(style: String? = nil, size: Double? = nil, weight: Weight? = nil) {
        self.style = style
        self.size = size
        self.weight = weight
    }

    public enum Weight: String, Equatable, Sendable {
        case ultraLight, thin, light, regular, medium, semibold, bold, heavy, black
    }

    public static let largeTitle = Font(style: "largeTitle")
    public static let title = Font(style: "title")
    public static let title2 = Font(style: "title2")
    public static let title3 = Font(style: "title3")
    public static let headline = Font(style: "headline")
    public static let subheadline = Font(style: "subheadline")
    public static let body = Font(style: "body")
    public static let callout = Font(style: "callout")
    public static let footnote = Font(style: "footnote")
    public static let caption = Font(style: "caption")
    public static let caption2 = Font(style: "caption2")

    public static func system(size: Double, weight: Weight? = nil) -> Font {
        Font(size: size, weight: weight)
    }

    public func weight(_ weight: Weight) -> Font {
        var copy = self
        copy.weight = weight
        return copy
    }

    public func bold() -> Font { weight(.bold) }
}

public struct _FontModifier: RenderModifier {
    let font: Font
    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = [:]
        if let style = font.style { args["style"] = .string(style) }
        if let size = font.size { args["size"] = .double(size) }
        if let weight = font.weight { args["weight"] = .string(weight.rawValue) }
        return ModifierNode(kind: "font", args: args)
    }
}

public extension View {
    func font(_ font: Font) -> ModifiedContent<Self, _FontModifier> {
        modifier(_FontModifier(font: font))
    }
}

// MARK: - Foreground color

public struct _ForegroundColorModifier: RenderModifier {
    let color: Color
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "foregroundColor", args: ["color": color.propValue])
    }
}

public extension View {
    func foregroundColor(_ color: Color) -> ModifiedContent<Self, _ForegroundColorModifier> {
        modifier(_ForegroundColorModifier(color: color))
    }
    func foregroundStyle(_ color: Color) -> ModifiedContent<Self, _ForegroundColorModifier> {
        modifier(_ForegroundColorModifier(color: color))
    }
}

// MARK: - Weight

public struct _FontWeightModifier: RenderModifier {
    let weight: Font.Weight
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "fontWeight", args: ["weight": .string(weight.rawValue)])
    }
}

public extension View {
    func fontWeight(_ weight: Font.Weight) -> ModifiedContent<Self, _FontWeightModifier> {
        modifier(_FontWeightModifier(weight: weight))
    }
    func bold() -> ModifiedContent<Self, _FontWeightModifier> {
        modifier(_FontWeightModifier(weight: .bold))
    }
}

// MARK: - Italic

public struct _ItalicModifier: RenderModifier {
    public var _modifierNode: ModifierNode { ModifierNode(kind: "italic") }
}

public extension View {
    func italic() -> ModifiedContent<Self, _ItalicModifier> {
        modifier(_ItalicModifier())
    }
}

// MARK: - Line limit

public struct _LineLimitModifier: RenderModifier {
    let limit: Int?
    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = [:]
        if let limit { args["count"] = .int(limit) }
        return ModifierNode(kind: "lineLimit", args: args)
    }
}

public extension View {
    func lineLimit(_ number: Int?) -> ModifiedContent<Self, _LineLimitModifier> {
        modifier(_LineLimitModifier(limit: number))
    }
}

// MARK: - Multiline text alignment

public enum TextAlignment: String, Equatable, Sendable {
    case leading, center, trailing
}

public struct _MultilineTextAlignmentModifier: RenderModifier {
    let alignment: TextAlignment
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "multilineTextAlignment", args: ["value": .string(alignment.rawValue)])
    }
}

public extension View {
    func multilineTextAlignment(_ alignment: TextAlignment) -> ModifiedContent<Self, _MultilineTextAlignmentModifier> {
        modifier(_MultilineTextAlignmentModifier(alignment: alignment))
    }
}
