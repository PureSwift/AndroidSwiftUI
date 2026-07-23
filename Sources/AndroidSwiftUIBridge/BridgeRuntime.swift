//
//  BridgeRuntime.swift
//  AndroidSwiftUIBridge
//
//  Drives a ViewHost against a Kotlin TreeStore: evaluate → materialize →
//  update, re-running on every state change.
//

import AndroidSwiftUICore

public final class BridgeRuntime {

    /// The active runtime; the callback sink dispatches into its registry.
    /// One UI tree per process for now (matches one Activity / one window).
    public private(set) static var current: BridgeRuntime?

    let host: ViewHost
    let store: TreeStore
    /// Runs a block on the platform main thread. JNI object creation and Compose
    /// state writes must happen there — a native background thread (e.g. a Swift
    /// `Task` driving an async state write) has neither the app class loader nor
    /// the right to touch Compose state.
    let scheduler: (@escaping () -> Void) -> Void
    private var needsRender = false

    public init(
        root: any View,
        store: TreeStore,
        scheduler: @escaping (@escaping () -> Void) -> Void = { $0() }
    ) {
        self.host = ViewHost(root)
        self.store = store
        self.scheduler = scheduler
        self.host.onStateChange = { [weak self] in
            self?.setNeedsRender()
        }
    }

    /// Installs this runtime as the process-wide dispatch target and renders
    /// the first tree.
    public func start() {
        BridgeRuntime.current = self
        push()
    }

    /// Coalesces state changes into one scheduled render on the main thread.
    /// Never evaluates synchronously inside a callback (avoids reentrancy).
    private func setNeedsRender() {
        guard !needsRender else { return }
        needsRender = true
        scheduler { [weak self] in
            guard let self else { return }
            self.needsRender = false
            self.push()
        }
    }

    func push() {
        let tree = host.evaluate()
        store.update(Materializer.materialize(tree))
    }

    // Dispatch entry points, called by the callback sink.

    public func invokeVoid(_ id: Int64) { host.callbacks.invokeVoid(id) }
    public func invokeBool(_ id: Int64, _ value: Bool) { host.callbacks.invokeBool(id, value) }
    public func invokeDouble(_ id: Int64, _ value: Double) { host.callbacks.invokeDouble(id, value) }
    public func invokeInt(_ id: Int64, _ value: Int) { host.callbacks.invokeInt(id, value) }
    public func invokeString(_ id: Int64, _ value: String) { host.callbacks.invokeString(id, value) }

    /// Resolves a lazy row and materializes it for the interpreter. Runs during
    /// Compose composition — a pure read.
    public func itemNode(_ id: Int64, _ index: Int) -> ViewNodeObject? {
        guard let node = host.callbacks.item(id, index) else { return nil }
        return Materializer.materialize(node)
    }
}
