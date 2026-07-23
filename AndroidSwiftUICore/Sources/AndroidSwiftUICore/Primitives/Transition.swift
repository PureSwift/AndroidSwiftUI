//
//  Transition.swift
//  AndroidSwiftUICore
//
//  `.transition(_:)` describes how a view animates in and out as it is inserted
//  into or removed from the tree (typically inside a `withAnimation`). The
//  interpreter wraps a transition-carrying child of a stack in an
//  AnimatedVisibility whose enter/exit is derived from the transition kind.
//

public enum Edge: String, Sendable {
    case top, bottom, leading, trailing
}

public struct AnyTransition: Equatable, Sendable {

    internal let kind: String
    internal let edge: String?

    private init(kind: String, edge: String? = nil) {
        self.kind = kind
        self.edge = edge
    }

    public static let identity = AnyTransition(kind: "identity")
    public static let opacity = AnyTransition(kind: "opacity")
    public static let slide = AnyTransition(kind: "slide")
    public static let scale = AnyTransition(kind: "scale")

    public static func move(edge: Edge) -> AnyTransition {
        AnyTransition(kind: "move", edge: edge.rawValue)
    }
}

public struct _TransitionModifier: RenderModifier {
    let transition: AnyTransition
    public var _modifierNode: ModifierNode {
        var args: [String: PropValue] = ["kind": .string(transition.kind)]
        if let edge = transition.edge { args["edge"] = .string(edge) }
        return ModifierNode(kind: "transition", args: args)
    }
}

public extension View {
    func transition(_ transition: AnyTransition) -> ModifiedContent<Self, _TransitionModifier> {
        modifier(_TransitionModifier(transition: transition))
    }
}
