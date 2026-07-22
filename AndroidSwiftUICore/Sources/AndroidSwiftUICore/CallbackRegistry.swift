//
//  CallbackRegistry.swift
//  AndroidSwiftUICore
//
//  Event closures can't cross the JNI boundary; nodes carry integer ids into
//  this table instead, and the fixed Kotlin→Swift dispatcher looks them up.
//  Ids are generation-tagged so a stale event (dispatched just before an
//  update) still resolves for one cycle before its entry is reclaimed.
//

public final class CallbackRegistry {

    public enum Callback {
        case void(() -> Void)
        case bool((Bool) -> Void)
        case double((Double) -> Void)
        case int((Int) -> Void)
        case string((String) -> Void)
    }

    private var current: [Int64: Callback] = [:]
    private var previous: [Int64: Callback] = [:]
    private var generation: Int32 = 0
    private var counter: Int32 = 0

    public init() {}

    /// Begins a fresh evaluation generation. The prior generation stays
    /// resolvable for one cycle so in-flight events don't dangle.
    public func beginGeneration() {
        previous = current
        current = [:]
        generation &+= 1
        counter = 0
    }

    /// Registers a callback, returning its id (high 32 bits = generation).
    public func register(_ callback: Callback) -> Int64 {
        let id = (Int64(generation) << 32) | Int64(counter)
        counter &+= 1
        current[id] = callback
        return id
    }

    /// Looks up a callback in the current or immediately-previous generation.
    public func callback(for id: Int64) -> Callback? {
        current[id] ?? previous[id]
    }

    // Typed dispatch entry points, matching the fixed Kotlin surface.

    public func invokeVoid(_ id: Int64) {
        if case .void(let action)? = callback(for: id) { action() }
    }

    public func invokeBool(_ id: Int64, _ value: Bool) {
        if case .bool(let action)? = callback(for: id) { action(value) }
    }

    public func invokeDouble(_ id: Int64, _ value: Double) {
        if case .double(let action)? = callback(for: id) { action(value) }
    }

    public func invokeInt(_ id: Int64, _ value: Int) {
        if case .int(let action)? = callback(for: id) { action(value) }
    }

    public func invokeString(_ id: Int64, _ value: String) {
        if case .string(let action)? = callback(for: id) { action(value) }
    }
}
