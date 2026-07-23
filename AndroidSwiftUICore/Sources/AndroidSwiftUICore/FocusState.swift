//
//  FocusState.swift
//  AndroidSwiftUICore
//
//  Keyboard focus as bindable state. `@FocusState` stores its value in the same
//  persisted box `@State` uses, so it survives re-evaluation; `.focused(_:)`
//  links a field to it, driving focus when Swift writes the value and reporting
//  back when the user moves focus themselves.
//

/// A property wrapper holding which field (if any) currently has focus.
///
/// Use `Bool` for a single field, or an optional `Hashable` to arbitrate
/// between several: `@FocusState private var focused: Field?`.
@propertyWrapper
public struct FocusState<Value: Hashable>: DynamicProperty {

    internal let box: StateBox<Value>

    public init(wrappedValue value: Value) {
        self.box = StateBox(value)
    }

    public var wrappedValue: Value {
        get { box.value }
        nonmutating set { box.value = newValue }
    }

    public var projectedValue: Binding {
        Binding(box: box)
    }

    /// The `$`-projection `.focused(_:)` accepts. Distinct from `SwiftUI.Binding`
    /// so only focus state can be bound to a field's focus.
    @propertyWrapper
    public struct Binding {

        internal let box: StateBox<Value>

        public var wrappedValue: Value {
            get { box.value }
            nonmutating set { box.value = newValue }
        }

        public var projectedValue: Binding { self }
    }
}

public extension FocusState where Value == Bool {
    init() { self.init(wrappedValue: false) }
}

public extension FocusState where Value: ExpressibleByNilLiteral {
    init() { self.init(wrappedValue: nil) }
}

extension FocusState: _StatePropertyReflectable {
    public var _box: AnyObject { box }
}

// MARK: - focused

public struct _FocusedModifier: RenderModifier, _CallbackModifier {

    /// Whether this field is the one the focus state currently names.
    let isFocused: Bool
    /// Called by the interpreter as the field gains (true) or loses (false) focus.
    let setFocused: (Bool) -> Void

    public var _modifierNode: ModifierNode { ModifierNode(kind: "focused") }

    public func _callbackNode(in context: ResolveContext) -> ModifierNode {
        let id = context.callbacks.register(.bool(setFocused))
        return ModifierNode(kind: "focused", args: [
            "isFocused": .bool(isFocused),
            "onChange": .int(Int(id)),
        ])
    }
}

public extension View {

    /// Binds this field's focus to a `Bool` focus state.
    func focused(_ condition: FocusState<Bool>.Binding) -> ModifiedContent<Self, _FocusedModifier> {
        modifier(_FocusedModifier(
            isFocused: condition.wrappedValue,
            setFocused: { gained in
                if gained {
                    condition.wrappedValue = true
                } else if condition.wrappedValue {
                    condition.wrappedValue = false
                }
            }
        ))
    }

    /// Binds this field's focus to `value` within a shared focus state.
    func focused<V: Hashable>(
        _ binding: FocusState<V?>.Binding,
        equals value: V
    ) -> ModifiedContent<Self, _FocusedModifier> {
        modifier(_FocusedModifier(
            isFocused: binding.wrappedValue == value,
            setFocused: { gained in
                if gained {
                    binding.wrappedValue = value
                } else if binding.wrappedValue == value {
                    // only surrender focus if it is still ours — a sibling that
                    // just took focus must not be cleared by our blur
                    binding.wrappedValue = nil
                }
            }
        ))
    }
}
