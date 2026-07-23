//
//  Bindable.swift
//  AndroidSwiftUICore
//
//  `@Bindable` wraps a reference to an `@Observable` model and projects a
//  two-way `Binding` into any of its properties via `$model.property`. Because
//  it wraps an existing reference (from `@State`, `@Environment`, or an init
//  parameter), it needs no state storage of its own — writes go straight
//  through the reference, and the model's observation drives re-evaluation.
//

@propertyWrapper
@dynamicMemberLookup
public struct Bindable<Value: AnyObject> {

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: Bindable<Value> { self }

    /// Projects a binding to a property of the wrapped reference. A reference
    /// keypath means the set writes through the object without reassigning it.
    public subscript<Subject>(
        dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>
    ) -> Binding<Subject> {
        let object = wrappedValue
        return Binding<Subject>(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
