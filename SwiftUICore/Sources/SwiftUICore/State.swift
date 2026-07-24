//
//  State.swift
//  SwiftUICore
//
//  Ported from the ClassicUICore design (MillerTechnologyPeru/ClassicUI):
//  views are value types rebuilt every pass, so @State stores its value in a
//  reference box; the evaluator persists boxes per identity path and re-links
//  fresh view values to their persisted storage before each body evaluation.
//

/// A stored variable that participates in view updates.
public protocol DynamicProperty {
    mutating func update()
}

public extension DynamicProperty {
    mutating func update() {}
}

/// A property wrapper for view-local mutable state.
@propertyWrapper
public struct State<Value>: DynamicProperty {

    internal let box: StateBox<Value>

    public init(wrappedValue value: Value) {
        self.box = StateBox(value)
    }

    public init(initialValue value: Value) {
        self.init(wrappedValue: value)
    }

    public var wrappedValue: Value {
        get { box.value }
        nonmutating set { box.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        Binding(get: { box.value }, set: { box.value = $0 })
    }
}

extension State: @unchecked Sendable where Value: Sendable {}

// MARK: - Storage

/// Type-erased access to a state box, used to reconnect fresh views to storage.
internal protocol _AnyStateBox: AnyObject {
    func _link(to box: AnyObject)
    func _setOnChange(_ handler: (() -> Void)?)
}

/// Views expose their `State`/`Binding`-backed properties through this.
public protocol _StatePropertyReflectable {
    var _box: AnyObject { get }
}

extension State: _StatePropertyReflectable {
    public var _box: AnyObject { box }
}

internal final class StateBox<Value>: _AnyStateBox {

    private var stored: Value
    private var target: StateBox<Value>?
    private var onChange: (() -> Void)?

    init(_ value: Value) { self.stored = value }

    var value: Value {
        get { target?.value ?? stored }
        set {
            if let target {
                target.value = newValue
            } else {
                stored = newValue
                onChange?()
            }
        }
    }

    func _link(to box: AnyObject) {
        guard box !== self, let box = box as? StateBox<Value> else { return }
        target = box
    }

    func _setOnChange(_ handler: (() -> Void)?) {
        onChange = handler
    }
}

/// Per-scope storage of state boxes, keyed by structural identity path.
///
/// A fresh box seen at a path becomes the persisted source of truth; later
/// passes link new boxes to it. Popping the owning scope discards its storage,
/// which is how `@State` lifetime tracks view lifetime.
public final class StateStorage {

    private var boxes: [String: _AnyStateBox] = [:]
    private let reflector: StateReflector

    /// Fired after any state write; the runtime schedules a re-evaluation.
    public var onChange: (() -> Void)?

    public init(reflector: StateReflector = MirrorStateReflector()) {
        self.reflector = reflector
    }

    private var persistentObjects: [String: AnyObject] = [:]

    /// Retrieves (or creates) a persistent reference object keyed by identity
    /// path — the backing store for container state like a navigation stack,
    /// which must survive re-evaluation without living in a view's `@State`.
    public func persistentObject<T: AnyObject>(at path: String, create: () -> T) -> T {
        if let existing = persistentObjects[path] as? T {
            return existing
        }
        let object = create()
        persistentObjects[path] = object
        return object
    }

    /// Registers the state properties of a freshly built view at `path`.
    public func install(in view: any View, path: String) {
        reflector.forEachStateProperty(in: view) { label, anyBox in
            guard let box = anyBox as? _AnyStateBox else { return }
            let key = "\(path).\(label)"
            if let persisted = boxes[key] {
                if persisted !== box {
                    box._link(to: persisted)
                }
            } else {
                boxes[key] = box
                box._setOnChange(onChange)
            }
        }
    }
}

// MARK: - Reflection seam

/// Discovers a view's state-backed properties. `MirrorStateReflector` is the
/// default; a macro/registration-based implementation can replace it later
/// (e.g. for Embedded Swift) without touching `StateStorage`'s callers.
public protocol StateReflector {
    func forEachStateProperty(in view: any View, _ body: (_ label: String, _ box: AnyObject) -> Void)
}

/// Mirror-based property discovery.
public struct MirrorStateReflector: StateReflector {

    public init() {}

    public func forEachStateProperty(
        in view: any View,
        _ body: (_ label: String, _ box: AnyObject) -> Void
    ) {
        var index = 0
        for child in Mirror(reflecting: view).children {
            defer { index += 1 }
            guard let property = child.value as? _StatePropertyReflectable else { continue }
            // strip the leading underscore Swift gives property-wrapper storage
            let label = child.label.map { $0.hasPrefix("_") ? String($0.dropFirst()) : $0 } ?? "_\(index)"
            body(label, property._box)
        }
    }
}
