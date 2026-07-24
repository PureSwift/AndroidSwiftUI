//
//  Preferences.swift
//  AndroidSwiftUICore
//
//  Child-to-parent data flow. Unlike `GeometryReader`, none of this crosses the
//  bridge: a preference is set and reduced entirely within one Swift resolve
//  pass, so the interpreter never learns preferences exist. `onPreferenceChange`
//  installs a collector for its subtree, resolves it, and reads the reduction.
//

/// A value a view publishes to its ancestors, combined across the subtree by
/// `reduce`.
public protocol PreferenceKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static func reduce(value: inout Value, nextValue: () -> Value)
}

/// Accumulates the preferences declared in one subtree, keyed by type.
public final class PreferenceCollector {

    private var values: [ObjectIdentifier: Any] = [:]
    /// One closure per key that folds this collector's value into another.
    /// Values are type-erased, so re-reducing them elsewhere needs the concrete
    /// key type captured here at record time.
    private var mergers: [ObjectIdentifier: (PreferenceCollector) -> Void] = [:]

    public init() {}

    /// Folds one published value in, starting from the key's default so the
    /// reduction is the same whether or not anything published before.
    internal func record<K: PreferenceKey>(_ key: K.Type, _ value: K.Value) {
        let id = ObjectIdentifier(key)
        var current = (values[id] as? K.Value) ?? K.defaultValue
        K.reduce(value: &current, nextValue: { value })
        values[id] = current
        let reduced = current
        mergers[id] = { parent in parent.record(key, reduced) }
    }

    internal func value<K: PreferenceKey>(for key: K.Type) -> K.Value {
        (values[ObjectIdentifier(key)] as? K.Value) ?? K.defaultValue
    }

    /// Folds everything collected here into `other`.
    ///
    /// An observer scopes a collector to its subtree, but it must not swallow
    /// the keys it isn't watching — an ancestor observing a *different* key
    /// still needs to see what that subtree published.
    internal func propagate(into other: PreferenceCollector) {
        for merge in mergers.values { merge(other) }
    }
}

/// Remembers the last value delivered for one key so an unchanged reduction
/// doesn't fire the callback again — without this the write the callback
/// usually performs would re-evaluate forever.
internal final class PreferenceMemo<Value: Equatable> {
    private var last: Value?
    func shouldDeliver(_ value: Value) -> Bool {
        guard last != value else { return false }
        last = value
        return true
    }
}

// MARK: - preference

public struct _PreferenceView<Content: View, K: PreferenceKey>: View {
    internal let key: K.Type
    internal let value: K.Value
    internal let content: Content
    public typealias Body = Never
}

extension _PreferenceView: _ResolutionEffectView {
    public func _applyEffect(_ context: inout ResolveContext) -> any View {
        context.preferences?.record(key, value)
        return content
    }
}

// MARK: - onPreferenceChange

public struct _OnPreferenceChangeView<Content: View, K: PreferenceKey>: View where K.Value: Equatable {
    internal let key: K.Type
    internal let action: (K.Value) -> Void
    internal let content: Content
    public typealias Body = Never
}

extension _OnPreferenceChangeView: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        // A fresh collector scopes the reduction to this subtree; resolving at
        // the same path keeps the wrapper identity-transparent.
        let collector = PreferenceCollector()
        var childContext = context
        childContext.preferences = collector
        let node = Evaluator.resolve(content, childContext)

        let value = collector.value(for: key)
        // Everything published here keeps flowing upward, not just the observed
        // key: chained observers each scope a collector, and dropping the rest
        // would strand an ancestor watching a different key.
        if let parent = context.preferences {
            collector.propagate(into: parent)
        }

        // Keyed by the preference type, not just the path: chained observers sit
        // at the SAME identity path, so a shared key would let each overwrite the
        // other's memo, make every delivery look new, and re-evaluate forever.
        let memoPath = context.path + ".preference." + String(describing: K.self)
        let memo = context.storage.persistentObject(at: memoPath) {
            PreferenceMemo<K.Value>()
        }
        if memo.shouldDeliver(value) {
            action(value)
        }
        return node
    }
}

public extension View {

    /// Publishes a value to ancestors observing `key`.
    func preference<K: PreferenceKey>(key: K.Type, value: K.Value) -> _PreferenceView<Self, K> {
        _PreferenceView(key: key, value: value, content: self)
    }

    /// Observes the reduced value of `key` across this view's subtree.
    func onPreferenceChange<K: PreferenceKey>(
        _ key: K.Type,
        perform action: @escaping (K.Value) -> Void
    ) -> _OnPreferenceChangeView<Self, K> where K.Value: Equatable {
        _OnPreferenceChangeView(key: key, action: action, content: self)
    }
}
