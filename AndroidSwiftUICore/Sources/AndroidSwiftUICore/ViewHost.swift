//
//  ViewHost.swift
//  AndroidSwiftUICore
//
//  Owns a root view's state storage and callback registry, produces the
//  current RenderNode tree, and re-evaluates when state changes. Platform-
//  agnostic: the Android bridge and the desktop test rig both drive it the
//  same way; the tests drive it directly.
//

public final class ViewHost {

    private let root: any View
    private let storage: StateStorage
    public let callbacks = CallbackRegistry()

    /// Called after a state write triggers a re-evaluation. The platform layer
    /// wires this to schedule an `evaluate()` on the main looper and push the
    /// result across the bridge; tests read `evaluate()` directly instead.
    public var onStateChange: (() -> Void)?

    public init(_ root: any View, reflector: StateReflector = MirrorStateReflector()) {
        self.root = root
        self.storage = StateStorage(reflector: reflector)
        self.storage.onChange = { [weak self] in
            self?.onStateChange?()
        }
    }

    /// Resolves the current view tree to a node tree. Each call opens a fresh
    /// callback generation, so ids in the returned tree are current.
    public func evaluate() -> RenderNode {
        callbacks.beginGeneration()
        let context = ResolveContext(storage: storage, callbacks: callbacks, path: "root")
        return Evaluator.resolve(root, context)
    }
}
