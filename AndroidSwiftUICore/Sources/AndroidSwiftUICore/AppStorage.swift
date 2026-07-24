//
//  AppStorage.swift
//  AndroidSwiftUICore
//
//  Values that outlive the process. The core owns no platform APIs, so the
//  backing store is a protocol the host installs — a JSON file under the app's
//  files directory on Android, an in-memory store in tests. Reads and writes
//  go through the same `StateBox` machinery `@State` uses, so a change marks the
//  view dirty exactly like any other state write.
//

import Foundation

/// Where `@AppStorage` values are kept between launches.
public protocol AppStorageBackend: AnyObject {
    func value(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
}

/// The process-wide store. Defaults to memory so the core works — and tests —
/// without a host; `ViewHost` installs a persistent one on Android.
public enum AppStorageStore {

    nonisolated(unsafe) public static var backend: AppStorageBackend = InMemoryAppStorage()

    internal static func read<Value>(_ key: String, as type: Value.Type) -> Value? {
        backend.value(forKey: key) as? Value
    }

    internal static func write(_ value: Any?, _ key: String) {
        backend.set(value, forKey: key)
    }
}

public final class InMemoryAppStorage: AppStorageBackend {
    private var values: [String: Any] = [:]
    public init() {}
    public func value(forKey key: String) -> Any? { values[key] }
    public func set(_ value: Any?, forKey key: String) { values[key] = value }
}

/// A JSON file on disk. Small by design: `@AppStorage` is for preferences, and
/// rewriting the whole file per write keeps it consistent without a database.
public final class FileAppStorage: AppStorageBackend {

    private let url: URL
    private var values: [String: Any]

    public init(directory: String, name: String = "app-storage.json") {
        self.url = URL(fileURLWithPath: directory).appendingPathComponent(name)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            self.values = decoded
        } else {
            self.values = [:]
        }
    }

    public func value(forKey key: String) -> Any? { values[key] }

    public func set(_ value: Any?, forKey key: String) {
        if let value { values[key] = value } else { values.removeValue(forKey: key) }
        guard let data = try? JSONSerialization.data(withJSONObject: values) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

// MARK: - The wrapper

/// A value persisted under `key`, readable and writable like `@State`.
@propertyWrapper
public struct AppStorage<Value>: DynamicProperty {

    internal let box: StateBox<Value>
    internal let key: String

    private init(key: String, defaultValue: Value) {
        self.key = key
        // seed from the store so the first read already reflects what was saved
        self.box = StateBox(AppStorageStore.read(key, as: Value.self) ?? defaultValue)
    }

    public var wrappedValue: Value {
        get { box.value }
        nonmutating set {
            box.value = newValue
            AppStorageStore.write(newValue, key)
        }
    }

    public var projectedValue: Binding<Value> {
        let key = self.key
        let box = self.box
        return Binding(
            get: { box.value },
            set: { box.value = $0; AppStorageStore.write($0, key) }
        )
    }
}

// Only the types a preferences store can round-trip through JSON.
public extension AppStorage where Value == Bool {
    init(wrappedValue: Value, _ key: String) { self.init(key: key, defaultValue: wrappedValue) }
}
public extension AppStorage where Value == Int {
    init(wrappedValue: Value, _ key: String) { self.init(key: key, defaultValue: wrappedValue) }
}
public extension AppStorage where Value == Double {
    init(wrappedValue: Value, _ key: String) { self.init(key: key, defaultValue: wrappedValue) }
}
public extension AppStorage where Value == String {
    init(wrappedValue: Value, _ key: String) { self.init(key: key, defaultValue: wrappedValue) }
}

extension AppStorage: _StatePropertyReflectable {
    public var _box: AnyObject { box }
}
