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

    public init(root: any View, store: TreeStore) {
        self.host = ViewHost(root)
        self.store = store
        // UI events arrive on the platform main thread (Compose dispatch), and
        // state writes inside them re-evaluate synchronously here. Event
        // callbacks run outside composition, so assigning the store's Compose
        // state from them is the standard, safe path. Cross-thread writes get
        // a scheduler when async state arrives (R5).
        self.host.onStateChange = { [weak self] in
            self?.push()
        }
    }

    /// Installs this runtime as the process-wide dispatch target and renders
    /// the first tree.
    public func start() {
        BridgeRuntime.current = self
        push()
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
}
