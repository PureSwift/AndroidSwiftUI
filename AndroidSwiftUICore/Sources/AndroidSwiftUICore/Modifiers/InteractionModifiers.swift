//
//  InteractionModifiers.swift
//  AndroidSwiftUICore
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

public struct _TaskModifier: RenderModifier, _CallbackModifier {
    let action: @Sendable () async -> Void
    public var _modifierNode: ModifierNode { ModifierNode(kind: "task") }
    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        // The interpreter fires this once on appear; the closure runs as a Task.
        // (v1 does not cancel it on disappear.)
        let action = self.action
        let id = context.callbacks.register(.void { Task { await action() } })
        return ModifierNode(kind: "task", args: ["action": .int(Int(id))])
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
