//
//  ViewBuilder.swift
//  SwiftUICore
//
//  Parameter packs give an arbitrary-arity buildBlock from day one (no
//  ten-child ceiling). buildEither produces _ConditionalContent, whose distinct
//  branch identity is what makes "state resets when a conditional flips" hold.
//

@resultBuilder
public enum ViewBuilder {

    public static func buildBlock() -> EmptyView { EmptyView() }

    public static func buildBlock<Content: View>(_ content: Content) -> Content { content }

    public static func buildBlock<each Content: View>(
        _ content: repeat each Content
    ) -> TupleView<(repeat each Content)> {
        TupleView((repeat each content))
    }

    public static func buildExpression<Content: View>(_ content: Content) -> Content { content }

    public static func buildOptional<Content: View>(_ content: Content?) -> Content? { content }

    public static func buildIf<Content: View>(_ content: Content?) -> Content? { content }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        _ConditionalContent(storage: .trueContent(first))
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        _ConditionalContent(storage: .falseContent(second))
    }

    public static func buildLimitedAvailability<Content: View>(_ content: Content) -> AnyView {
        AnyView(content)
    }
}

/// A view created from a tuple of view values.
public struct TupleView<T>: View {
    public var value: T
    public init(_ value: T) { self.value = value }
    public typealias Body = Never
}

/// View content showing one of two possible children.
public struct _ConditionalContent<TrueContent: View, FalseContent: View>: View {

    internal enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    internal let storage: Storage
    public typealias Body = Never
}
