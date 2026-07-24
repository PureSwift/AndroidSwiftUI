//
//  Binding.swift
//  SwiftUICore
//

/// A two-way connection to a mutable value owned elsewhere.
@propertyWrapper
public struct Binding<Value> {

    private let get: () -> Value
    private let set: (Value) -> Void

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    public var projectedValue: Binding<Value> { self }

    /// Derives a binding to a member of the wrapped value.
    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> Binding<Subject> {
        Binding<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { newValue in
                var value = self.wrappedValue
                value[keyPath: keyPath] = newValue
                self.wrappedValue = value
            }
        )
    }

    /// A constant binding, useful for previews and tests.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}

extension Binding: @unchecked Sendable where Value: Sendable {}
