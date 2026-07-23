//
//  Environment.swift
//  AndroidSwiftUICore
//
//  Object environment: values flow DOWN the evaluation (they shape body
//  evaluation) and never cross the bridge. `@Environment(Model.self)` reads an
//  object a parent injected with `.environment(model)`.
//

/// Per-subtree environment values, keyed by object type.
public struct EnvironmentStorage {

    var objects: [ObjectIdentifier: AnyObject] = [:]

    public init() {}

    mutating func set(_ object: AnyObject) {
        objects[ObjectIdentifier(type(of: object))] = object
    }

    func object<T: AnyObject>(of type: T.Type) -> T? {
        objects[ObjectIdentifier(type)] as? T
    }
}

/// Reads an object from the environment.
@propertyWrapper
public struct Environment<Value: AnyObject> {

    internal let box = EnvironmentBox<Value>()

    public init(_ type: Value.Type) {}

    public var wrappedValue: Value {
        guard let value = box.value else {
            fatalError("@Environment(\(Value.self).self) read before injection — missing .environment(_:)?")
        }
        return value
    }
}

internal final class EnvironmentBox<Value: AnyObject> {
    var value: Value?
}

/// Type-erased injection hook, discovered via the reflection seam.
public protocol _EnvironmentProperty {
    func _inject(from storage: EnvironmentStorage)
}

extension Environment: _EnvironmentProperty {
    public func _inject(from storage: EnvironmentStorage) {
        box.value = storage.object(of: Value.self)
    }
}

/// The `.environment(_:)` wrapper: sets an object for the subtree.
public struct _EnvironmentWriterView<Content: View>: View {

    internal let object: AnyObject
    internal let content: Content

    public typealias Body = Never
}

public extension View {
    func environment<T: AnyObject>(_ object: T) -> _EnvironmentWriterView<Self> {
        _EnvironmentWriterView(object: object, content: self)
    }
}

/// Injects environment values into a view's `@Environment` properties.
public enum EnvironmentInjector {

    public static func inject(_ storage: EnvironmentStorage, into view: any View) {
        for child in Mirror(reflecting: view).children {
            if let property = child.value as? _EnvironmentProperty {
                property._inject(from: storage)
            }
        }
    }
}
