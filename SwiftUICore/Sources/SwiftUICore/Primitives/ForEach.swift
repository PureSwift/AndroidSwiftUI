//
//  ForEach.swift
//  SwiftUICore
//
//  Eager in R2: each element flattens inline, keyed by its identity so state
//  survives insert/remove. The lazy provider path (itemNode) lands in R7.
//

public struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {

    internal let data: Data
    internal let id: (Data.Element) -> ID
    internal let content: (Data.Element) -> Content

    public init(_ data: Data, id: @escaping (Data.Element) -> ID, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }

    public typealias Body = Never
}

public extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, id: { $0.id }, content: content)
    }
}

public extension ForEach where Data.Element: Hashable, ID == Data.Element {
    init(_ data: Data, id: KeyPath<Data.Element, Data.Element> = \.self, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, id: { $0 }, content: content)
    }
}

// Range convenience (ForEach(0..<n))
public extension ForEach where Data == Range<Int>, ID == Int, Content: View {
    init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data, id: { $0 }, content: content)
    }
}

extension ForEach: _GroupView {
    public func _flatten(into nodes: inout [RenderNode], context: ResolveContext) {
        for element in data {
            // keyed by identity, not position, so inserts don't shift state
            let key = "#\(identityString(id(element)))"
            Evaluator.flatten(content(element), into: &nodes, context: context.descending(key))
        }
    }
}

/// A stable string for an identity value, for use in identity paths.
internal func identityString<ID: Hashable>(_ id: ID) -> String {
    if let string = id as? String { return string }
    if let value = id as? CustomStringConvertible { return value.description }
    return String(describing: id)
}
