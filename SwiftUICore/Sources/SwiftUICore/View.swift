//
//  View.swift
//  SwiftUICore
//
//  The View protocol matches SwiftUI's, so app code written against it compiles
//  unchanged against real SwiftUI on Apple platforms.
//

/// A type that represents part of your app's user interface.
public protocol View {

    associatedtype Body: View

    @ViewBuilder var body: Body { get }
}

extension Never: View {
    public var body: Never { fatalError("Never has no instances") }
}

public extension View where Body == Never {
    /// Primitive views have no body; the evaluator resolves them directly.
    var body: Never { fatalError("body of primitive view \(Self.self) should never be evaluated") }
}

/// A view with no content.
public struct EmptyView: View {
    public init() {}
    public typealias Body = Never
}

/// A type-erased view.
public struct AnyView: View {

    internal let storage: any View

    public init<V: View>(_ view: V) {
        self.storage = view
    }

    public typealias Body = Never
}

extension Optional: View where Wrapped: View {
    public typealias Body = Never
    public var body: Never { fatalError("body of Optional view should never be evaluated") }
}
