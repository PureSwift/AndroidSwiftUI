//
//  AppearanceModifiers.swift
//  AndroidSwiftUICore
//
//  Visual modifiers that fold into the Compose Modifier chain: border, shadow,
//  and clipShape.
//

// MARK: - Border

public struct _BorderModifier: RenderModifier {
    let color: Color
    let width: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "border", args: ["color": color.propValue, "width": .double(width)])
    }
}

public extension View {
    func border(_ color: Color, width: Double = 1) -> ModifiedContent<Self, _BorderModifier> {
        modifier(_BorderModifier(color: color, width: width))
    }
}

// MARK: - Shadow

public struct _ShadowModifier: RenderModifier {
    let radius: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "shadow", args: ["radius": .double(radius)])
    }
}

public extension View {
    func shadow(radius: Double, x: Double = 0, y: Double = 0) -> ModifiedContent<Self, _ShadowModifier> {
        modifier(_ShadowModifier(radius: radius))
    }
    func shadow(color: Color, radius: Double, x: Double = 0, y: Double = 0) -> ModifiedContent<Self, _ShadowModifier> {
        modifier(_ShadowModifier(radius: radius))
    }
}

// MARK: - Clip shape

/// A shape reduced to the fields the interpreter needs to build a Compose shape.
public protocol _ShapeKind {
    var _shapeKind: String { get }
    var _cornerRadius: Double? { get }
}

extension Rectangle: _ShapeKind {
    public var _shapeKind: String { "rectangle" }
    public var _cornerRadius: Double? { nil }
}
extension Circle: _ShapeKind {
    public var _shapeKind: String { "circle" }
    public var _cornerRadius: Double? { nil }
}
extension Capsule: _ShapeKind {
    public var _shapeKind: String { "capsule" }
    public var _cornerRadius: Double? { nil }
}
extension RoundedRectangle: _ShapeKind {
    public var _shapeKind: String { "roundedRectangle" }
    public var _cornerRadius: Double? { cornerRadius }
}

public struct _ClipShapeModifier: RenderModifier {
    let kind: String
    let cornerRadius: Double?
    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = ["shape": .string(kind)]
        if let cornerRadius { args["cornerRadius"] = .double(cornerRadius) }
        return ModifierNode(kind: "clipShape", args: args)
    }
}

public extension View {
    func clipShape<S: _ShapeKind>(_ shape: S) -> ModifiedContent<Self, _ClipShapeModifier> {
        modifier(_ClipShapeModifier(kind: shape._shapeKind, cornerRadius: shape._cornerRadius))
    }
}

// MARK: - Tint

/// Sets the accent color for controls in the subtree (an environment value,
/// like `.foregroundColor`).
public struct _TintModifier: RenderModifier {
    let color: Color
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "tint", args: ["color": color.propValue])
    }
}

public extension View {
    func tint(_ color: Color) -> ModifiedContent<Self, _TintModifier> {
        modifier(_TintModifier(color: color))
    }
}
