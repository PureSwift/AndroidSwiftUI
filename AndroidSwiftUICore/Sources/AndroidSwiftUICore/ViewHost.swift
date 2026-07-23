//
//  ViewHost.swift
//  AndroidSwiftUICore
//
//  Owns a root view's state storage and callback registry, produces the
//  current RenderNode tree, and re-evaluates when state changes. Platform-
//  agnostic: the Android bridge and the desktop test rig both drive it the
//  same way; the tests drive it directly.
//

#if canImport(Observation)
import Observation
#endif

// Main-thread confined by contract (evaluation, callbacks, and state writes
// all happen on the platform main thread); @unchecked so the observation
// change handler — which is @Sendable — can reach onStateChange.
public final class ViewHost: @unchecked Sendable {

    private let root: any View
    private let storage: StateStorage
    public let callbacks = CallbackRegistry()

    /// Called after a state write triggers a re-evaluation. The platform layer
    /// wires this to schedule an `evaluate()` on the main looper and push the
    /// result across the bridge; tests read `evaluate()` directly instead.
    public var onStateChange: (() -> Void)?

    /// The animation captured from the transaction at write time, carried to
    /// the (coalesced) evaluation the write scheduled.
    private var pendingAnimation: Animation?

    public init(_ root: any View, reflector: StateReflector = MirrorStateReflector()) {
        self.root = root
        self.storage = StateStorage(reflector: reflector)
        self.storage.onChange = { [weak self] in
            if let animation = Transaction._current {
                self?.pendingAnimation = animation
            }
            self?.onStateChange?()
        }
    }

    /// Resolves the current view tree to a node tree. Each call opens a fresh
    /// callback generation, so ids in the returned tree are current.
    public func evaluate() -> RenderNode {
        callbacks.beginGeneration()
        let context = ResolveContext(storage: storage, callbacks: callbacks, path: "root")
        #if canImport(Observation)
        // Track @Observable reads during evaluation: a later mutation of any
        // observed property schedules a re-evaluation, exactly like a @State
        // write. Re-arms itself because the change handler triggers evaluate().
        var node = withObservationTracking {
            Evaluator.resolve(root, context)
        } onChange: { [weak self] in
            if let animation = Transaction._current {
                self?.pendingAnimation = animation
            }
            self?.onStateChange?()
        }
        #else
        var node = Evaluator.resolve(root, context)
        #endif
        // A tree produced by a withAnimation write carries the animation on its
        // root; the interpreter eases changed modifier values while it applies.
        if let animation = pendingAnimation {
            pendingAnimation = nil
            node.props["animationCurve"] = .string(animation.curve)
            node.props["animationDurationMs"] = .double(animation.duration * 1000)
        }
        return node
    }
}
