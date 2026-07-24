//
//  InteractionModifiers.swift
//  SwiftUICore
//
//  Gesture and lifecycle modifiers. These carry a closure, so they register a
//  callback against the resolve context (via `_CallbackModifier`) and embed its
//  id in the emitted node; the interpreter wires the id to a Compose
//  `clickable`, `DisposableEffect`, or `LaunchedEffect`.
//

// MARK: - onTapGesture

public struct _OnTapGestureModifier: RenderModifier, _CallbackModifier {
    let action: () -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "onTapGesture") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        return ModifierNode(kind: "onTapGesture", args: ["action": .int(Int(id))])
    }
}

public extension View {
    func onTapGesture(perform action: @escaping () -> Void) -> ModifiedContent<Self, _OnTapGestureModifier> {
        modifier(_OnTapGestureModifier(action: action))
    }
}

// MARK: - onAppear / onDisappear

public struct _OnAppearModifier: RenderModifier, _CallbackModifier {
    let action: () -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "onAppear") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        return ModifierNode(kind: "onAppear", args: ["action": .int(Int(id))])
    }
}

public struct _OnDisappearModifier: RenderModifier, _CallbackModifier {
    let action: () -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "onDisappear") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        return ModifierNode(kind: "onDisappear", args: ["action": .int(Int(id))])
    }
}

public extension View {
    func onAppear(perform action: @escaping () -> Void) -> ModifiedContent<Self, _OnAppearModifier> {
        modifier(_OnAppearModifier(action: action))
    }
    func onDisappear(perform action: @escaping () -> Void) -> ModifiedContent<Self, _OnDisappearModifier> {
        modifier(_OnDisappearModifier(action: action))
    }
}

// MARK: - task

/// Running `.task` closures, keyed by the view's stable identity path. Keying by
/// path (not the generation-scoped callback id) lets the cancel fired on disappear
/// stop the right Task no matter how many times the view re-evaluated in between.
enum _TaskRegistry {
    nonisolated(unsafe) static var running: [String: Task<Void, Never>] = [:]

    static func start(path: String, action: @escaping @Sendable () async -> Void) {
        running[path]?.cancel()                       // replace a stale run at this path
        running[path] = Task { await action() }
    }

    static func cancel(path: String) {
        running[path]?.cancel()
        running[path] = nil
    }
}

public struct _TaskModifier: RenderModifier, _CallbackModifier {
    let action: @Sendable () async -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "task") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        // Two callbacks: the interpreter fires `start` on appear and `cancel` on
        // disappear. The launched Task is stored by identity path, so the closure
        // it runs is cooperatively cancelled (Task.isCancelled / Task.sleep throws)
        // when the view leaves the tree.
        let action = self.action
        let path = context.path
        let start = context.callbacks.register(.void { _TaskRegistry.start(path: path, action: action) })
        let cancel = context.callbacks.register(.void { _TaskRegistry.cancel(path: path) })
        return ModifierNode(kind: "task", args: ["start": .int(Int(start)), "cancel": .int(Int(cancel))])
    }
}

public extension View {
    func task(_ action: @escaping @Sendable () async -> Void) -> ModifiedContent<Self, _TaskModifier> {
        modifier(_TaskModifier(action: action))
    }
}

// MARK: - onChange

public struct _OnChangeModifier<V: Equatable>: RenderModifier, _CallbackModifier {
    let value: V
    let action: () -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "onChange") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        // The interpreter fires the action when this token changes between
        // evaluations (skipping the first composition).
        return ModifierNode(kind: "onChange", args: [
            "token": .string(String(describing: value)),
            "action": .int(Int(id)),
        ])
    }
}

public extension View {
    func onChange<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> ModifiedContent<Self, _OnChangeModifier<V>> {
        modifier(_OnChangeModifier(value: value, action: action))
    }
}

// MARK: - disabled

public struct _DisabledModifier: RenderModifier {
    let disabled: Bool
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "disabled", args: ["value": .bool(disabled)])
    }
}

public extension View {
    func disabled(_ disabled: Bool) -> ModifiedContent<Self, _DisabledModifier> {
        modifier(_DisabledModifier(disabled: disabled))
    }
}
