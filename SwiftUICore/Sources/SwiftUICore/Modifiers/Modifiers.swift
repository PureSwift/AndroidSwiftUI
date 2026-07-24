//
//  Modifiers.swift
//  SwiftUICore
//
//  Modifiers are identity-transparent wrappers: they contribute an entry to
//  the node's ordered modifier chain without introducing a structural level.
//  The Compose interpreter folds the chain into a `Modifier` in list order.
//

/// A modifier that emits one `ModifierNode`.
public protocol RenderModifier {
    var _modifierNode: ModifierNode { get }
}

/// A view wrapped by a modifier.
public struct ModifiedContent<Content: View, Modifier: RenderModifier>: View {

    internal let content: Content
    internal let modifier: Modifier

    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public typealias Body = Never
}

extension ModifiedContent: _ModifierProvider {
    public var _modifierNode: ModifierNode { modifier._modifierNode }
    public var _modifiedContent: any View { content }
}

extension ModifiedContent: _ContextualModifierProvider {
    public func _modifierNode(in context: ResolveContext) -> ModifierNode {
        if let callback = modifier as? _CallbackModifier {
            return callback._callbackNode(in: context)
        }
        return modifier._modifierNode
    }
}

public extension View {
    func modifier<M: RenderModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(content: self, modifier: modifier)
    }
}

// MARK: - Edges & insets

public struct EdgeInsets: Equatable, Sendable {
    public var top, leading, bottom, trailing: Double
    public init(top: Double, leading: Double, bottom: Double, trailing: Double) {
        self.top = top; self.leading = leading; self.bottom = bottom; self.trailing = trailing
    }
    public init(_ all: Double) { self.init(top: all, leading: all, bottom: all, trailing: all) }
}

// MARK: - Padding

public struct _PaddingModifier: RenderModifier {
    let insets: EdgeInsets?
    public var _modifierNode: ModifierNode {
        if let insets {
            return ModifierNode(kind: "padding", args: [
                "top": .double(insets.top), "leading": .double(insets.leading),
                "bottom": .double(insets.bottom), "trailing": .double(insets.trailing),
            ])
        }
        return ModifierNode(kind: "padding", args: [:]) // default system padding
    }
}

public extension View {
    func padding(_ insets: EdgeInsets) -> ModifiedContent<Self, _PaddingModifier> {
        modifier(_PaddingModifier(insets: insets))
    }
    func padding(_ length: Double? = nil) -> ModifiedContent<Self, _PaddingModifier> {
        modifier(_PaddingModifier(insets: length.map { EdgeInsets($0) }))
    }
}

// MARK: - Frame

public struct _FrameModifier: RenderModifier {
    var width: Double? = nil
    var height: Double? = nil
    var minWidth: Double? = nil
    var idealWidth: Double? = nil
    var maxWidth: Double? = nil
    var minHeight: Double? = nil
    var idealHeight: Double? = nil
    var maxHeight: Double? = nil
    var alignment: Alignment = .center

    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = [:]
        if let width { args["width"] = .double(width) }
        if let height { args["height"] = .double(height) }
        if let minWidth { args["minWidth"] = .double(minWidth) }
        if let idealWidth { args["idealWidth"] = .double(idealWidth) }
        // .infinity can't cross as a JSON number, so a fill flag carries it.
        if let maxWidth {
            if maxWidth == .infinity { args["fillWidth"] = .bool(true) }
            else { args["maxWidth"] = .double(maxWidth) }
        }
        if let minHeight { args["minHeight"] = .double(minHeight) }
        if let idealHeight { args["idealHeight"] = .double(idealHeight) }
        if let maxHeight {
            if maxHeight == .infinity { args["fillHeight"] = .bool(true) }
            else { args["maxHeight"] = .double(maxHeight) }
        }
        if alignment.horizontal != .center || alignment.vertical != .center {
            args["horizontal"] = .string(alignment.horizontal.rawValue)
            args["vertical"] = .string(alignment.vertical.rawValue)
        }
        return ModifierNode(kind: "frame", args: args)
    }
}

public extension View {
    /// A fixed frame, optionally aligning the content within it.
    func frame(width: Double? = nil, height: Double? = nil, alignment: Alignment = .center) -> ModifiedContent<Self, _FrameModifier> {
        modifier(_FrameModifier(width: width, height: height, alignment: alignment))
    }

    /// A flexible frame with size bounds. `maxWidth`/`maxHeight` of `.infinity`
    /// expand to fill the available space.
    func frame(
        minWidth: Double? = nil,
        idealWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        idealHeight: Double? = nil,
        maxHeight: Double? = nil,
        alignment: Alignment = .center
    ) -> ModifiedContent<Self, _FrameModifier> {
        modifier(_FrameModifier(
            minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth,
            minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight,
            alignment: alignment
        ))
    }
}

// MARK: - Background (solid color)

public struct _BackgroundColorModifier: RenderModifier {
    let color: Color
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "background", args: ["color": color.propValue])
    }
}

public extension View {
    func background(_ color: Color) -> ModifiedContent<Self, _BackgroundColorModifier> {
        modifier(_BackgroundColorModifier(color: color))
    }
}

// MARK: - Corner radius

public struct _CornerRadiusModifier: RenderModifier {
    let radius: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "cornerRadius", args: ["radius": .double(radius)])
    }
}

public extension View {
    func cornerRadius(_ radius: Double) -> ModifiedContent<Self, _CornerRadiusModifier> {
        modifier(_CornerRadiusModifier(radius: radius))
    }
}

// MARK: - Offset

public struct _OffsetModifier: RenderModifier {
    let x: Double
    let y: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "offset", args: ["x": .double(x), "y": .double(y)])
    }
}

public extension View {
    func offset(x: Double = 0, y: Double = 0) -> ModifiedContent<Self, _OffsetModifier> {
        modifier(_OffsetModifier(x: x, y: y))
    }
}

// MARK: - Rotation

public struct _RotationModifier: RenderModifier {
    let degrees: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "rotation", args: ["degrees": .double(degrees)])
    }
}

public extension View {
    func rotationEffect(_ angle: Angle) -> ModifiedContent<Self, _RotationModifier> {
        modifier(_RotationModifier(degrees: angle.degrees))
    }
}

// MARK: - Scale

public struct _ScaleModifier: RenderModifier {
    let scale: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "scale", args: ["scale": .double(scale)])
    }
}

public extension View {
    func scaleEffect(_ scale: Double) -> ModifiedContent<Self, _ScaleModifier> {
        modifier(_ScaleModifier(scale: scale))
    }
}

// MARK: - Opacity

public struct _OpacityModifier: RenderModifier {
    let opacity: Double
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "opacity", args: ["opacity": .double(opacity)])
    }
}

public extension View {
    func opacity(_ opacity: Double) -> ModifiedContent<Self, _OpacityModifier> {
        modifier(_OpacityModifier(opacity: opacity))
    }
}
