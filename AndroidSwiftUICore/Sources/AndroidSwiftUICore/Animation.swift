//
//  Animation.swift
//  AndroidSwiftUICore
//
//  Animation is interpreter-side: Swift only describes intent. `withAnimation`
//  records the animation on the transaction; the state writes inside its body
//  mark the host's next evaluation, which stamps the root node. The Compose
//  interpreter then eases changed modifier values instead of snapping them.
//

/// A description of how value changes should be eased.
public struct Animation: Equatable, Sendable {

    internal var curve: String
    internal var duration: Double   // seconds

    public static let `default` = Animation(curve: "easeInOut", duration: 0.35)

    public static func linear(duration: Double = 0.35) -> Animation {
        Animation(curve: "linear", duration: duration)
    }

    public static func easeIn(duration: Double = 0.35) -> Animation {
        Animation(curve: "easeIn", duration: duration)
    }

    public static func easeOut(duration: Double = 0.35) -> Animation {
        Animation(curve: "easeOut", duration: duration)
    }

    public static func easeInOut(duration: Double = 0.35) -> Animation {
        Animation(curve: "easeInOut", duration: duration)
    }

    public static func spring() -> Animation {
        Animation(curve: "spring", duration: 0.5)
    }
}

/// The animation context active while a `withAnimation` body runs. Main-thread
/// confined by the same contract as the rest of the pipeline.
public enum Transaction {
    nonisolated(unsafe) public static var _current: Animation?
}

/// Runs `body`, easing the view updates its state writes produce.
public func withAnimation<Result>(
    _ animation: Animation = .default,
    _ body: () throws -> Result
) rethrows -> Result {
    let previous = Transaction._current
    Transaction._current = animation
    defer { Transaction._current = previous }
    return try body()
}

// MARK: - Implicit animation

/// Marks a view so changes to its modifier values ease whenever `value`
/// changes, without an explicit `withAnimation` at the write site.
public struct _AnimationModifier: RenderModifier {
    let animation: Animation?
    let token: String
    public var _modifierNode: ModifierNode {
        guard let animation else { return ModifierNode(kind: "animation") }
        return ModifierNode(kind: "animation", args: [
            "curve": .string(animation.curve),
            "durationMs": .double(animation.duration * 1000),
            "token": .string(token),
        ])
    }
}

public extension View {
    func animation<V: Equatable>(_ animation: Animation?, value: V) -> ModifiedContent<Self, _AnimationModifier> {
        modifier(_AnimationModifier(animation: animation, token: String(describing: value)))
    }
}
