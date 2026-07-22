//
//  Modifiers.swift
//  AndroidSwiftUICore
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
    let width: Double?
    let height: Double?
    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = [:]
        if let width { args["width"] = .double(width) }
        if let height { args["height"] = .double(height) }
        return ModifierNode(kind: "frame", args: args)
    }
}

public extension View {
    func frame(width: Double? = nil, height: Double? = nil) -> ModifiedContent<Self, _FrameModifier> {
        modifier(_FrameModifier(width: width, height: height))
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
