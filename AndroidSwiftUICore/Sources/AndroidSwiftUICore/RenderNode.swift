//
//  RenderNode.swift
//  AndroidSwiftUICore
//
//  The serializable description a resolved view tree produces. The Compose
//  interpreter consumes this; nothing here imports Android or the JVM, so the
//  whole evaluator is host-testable on macOS.
//

/// A leaf value carried by a node's props or a modifier's args.
public enum PropValue: Equatable, Sendable {
    case string(String)
    case double(Double)
    case bool(Bool)
    case int(Int)
    case array([PropValue])
}

/// One entry in a node's ordered modifier chain. Order is significant:
/// `.padding().background()` folds to a Compose `Modifier` in the same order.
public struct ModifierNode: Equatable, Sendable {

    public var kind: String
    public var args: [String: PropValue]

    public init(kind: String, args: [String: PropValue] = [:]) {
        self.kind = kind
        self.args = args
    }
}

/// A node in the resolved view tree.
///
/// `id` is the view's structural identity path — stable across re-evaluation,
/// so the interpreter can key Compose identity to it and state survives updates.
public struct RenderNode: Equatable, Sendable {

    /// Primitive kind: "Text", "VStack", "Button", …
    public var type: String

    /// Structural identity path (readable during evaluation; hashed at the bridge).
    public var id: String

    /// Type-specific properties.
    public var props: [String: PropValue]

    /// Ordered modifier chain applied to this node.
    public var modifiers: [ModifierNode]

    /// Eagerly resolved children.
    public var children: [RenderNode]

    /// Element count for a lazy container; `nil` for eager nodes.
    public var count: Int?

    public init(
        type: String,
        id: String,
        props: [String: PropValue] = [:],
        modifiers: [ModifierNode] = [],
        children: [RenderNode] = [],
        count: Int? = nil
    ) {
        self.type = type
        self.id = id
        self.props = props
        self.modifiers = modifiers
        self.children = children
        self.count = count
    }
}
