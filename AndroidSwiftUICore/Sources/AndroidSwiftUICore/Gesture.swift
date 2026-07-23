//
//  Gesture.swift
//  AndroidSwiftUICore
//
//  Continuous gestures. A drag reports through the fixed string callback rather
//  than growing the bridge with a two-number entry point: the interpreter sends
//  "<phase>;<startX>,<startY>;<x>,<y>" in points, which rebuilds a Value here.
//

import Foundation

/// A gesture recognized on a view. `.gesture(_:)` currently accepts `DragGesture`.
public protocol Gesture {}

public struct DragGesture: Gesture {

    /// The state of a drag as it is recognized.
    public struct Value {
        public var startLocation: CGPoint
        public var location: CGPoint
        public var translation: CGSize
    }

    /// How far the touch must move before the drag is recognized.
    public var minimumDistance: Double

    internal var changedAction: ((Value) -> Void)?
    internal var endedAction: ((Value) -> Void)?

    public init(minimumDistance: Double = 10) {
        self.minimumDistance = minimumDistance
    }

    public func onChanged(_ action: @escaping (Value) -> Void) -> DragGesture {
        var copy = self
        copy.changedAction = action
        return copy
    }

    public func onEnded(_ action: @escaping (Value) -> Void) -> DragGesture {
        var copy = self
        copy.endedAction = action
        return copy
    }
}

internal extension DragGesture.Value {

    /// Rebuilds a value from the interpreter's `"<phase>;<sx>,<sy>;<x>,<y>"`.
    init?(payload: String) {
        let fields = payload.split(separator: ";")
        guard fields.count == 3 else { return nil }
        let start = fields[1].split(separator: ",").compactMap { Double($0) }
        let current = fields[2].split(separator: ",").compactMap { Double($0) }
        guard start.count == 2, current.count == 2 else { return nil }
        self.startLocation = CGPoint(x: start[0], y: start[1])
        self.location = CGPoint(x: current[0], y: current[1])
        self.translation = CGSize(width: current[0] - start[0], height: current[1] - start[1])
    }
}

// MARK: - Modifiers

public struct _GestureModifier: RenderModifier, _CallbackModifier {

    let gesture: DragGesture

    public var _modifierNode: ModifierNode { ModifierNode(kind: "drag") }

    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let changed = gesture.changedAction
        let ended = gesture.endedAction
        let id = context.callbacks.register(.string { payload in
            guard let value = DragGesture.Value(payload: payload) else { return }
            if payload.hasPrefix("ended") {
                ended?(value)
            } else {
                changed?(value)
            }
        })
        return ModifierNode(kind: "drag", args: [
            "action": .int(Int(id)),
            "minimumDistance": .double(gesture.minimumDistance),
        ])
    }
}

public struct _LongPressModifier: RenderModifier, _CallbackModifier {

    let action: () -> Void

    public var _modifierNode: ModifierNode { ModifierNode(kind: "longPress") }

    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.void(action))
        return ModifierNode(kind: "longPress", args: ["action": .int(Int(id))])
    }
}

public extension View {

    func gesture(_ gesture: DragGesture) -> ModifiedContent<Self, _GestureModifier> {
        modifier(_GestureModifier(gesture: gesture))
    }

    func onLongPressGesture(perform action: @escaping () -> Void) -> ModifiedContent<Self, _LongPressModifier> {
        modifier(_LongPressModifier(action: action))
    }
}
