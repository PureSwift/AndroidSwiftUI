//
//  List.swift
//  SwiftUICore
//
//  A lazy list: rows are evaluated on demand through an item provider, so a
//  large list contributes one node plus the rows Compose actually asks for.
//  This is the only unbounded-tree case, and the reason the schema carries
//  `count` and `itemProviderID`.
//

public struct List<Data: RandomAccessCollection, ID: Hashable, RowContent: View>: View {

    internal let data: Data
    internal let id: (Data.Element) -> ID
    internal let row: (Data.Element) -> RowContent

    public init(_ data: Data, id: @escaping (Data.Element) -> ID, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.id = id
        self.row = rowContent
    }

    public typealias Body = Never
}

public extension List where Data.Element: Identifiable, ID == Data.Element.ID {
    init(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.init(data, id: { $0.id }, rowContent: rowContent)
    }
}

extension List: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        // snapshot the data and row builder; the provider resolves each row on
        // demand, keyed by element id so row @State survives scroll and reorder
        let elements = Array(data)
        let rowBuilder = row
        let keyFor = id
        let listPath = context.path
        let storage = context.storage
        let callbacks = context.callbacks
        let environment = context.environment

        let providerID = callbacks.register(.item { index in
            let element = elements[index]
            let key = "#\(identityString(keyFor(element)))"
            var rowContext = ResolveContext(
                storage: storage,
                callbacks: callbacks,
                environment: environment,
                path: listPath + "/" + key
            )
            return Evaluator.resolve(rowBuilder(element), rowContext)
        })

        let keys = elements.map { PropValue.string(identityString(keyFor($0))) }
        var props: [String: PropValue] = [
            "keys": .array(keys),
            "itemProvider": .int(Int(providerID)),
        ]
        if let onRefresh = context.refreshSink?.action {
            let refreshID = callbacks.register(.void {
                Task { await onRefresh() }
            })
            props["onRefresh"] = .int(Int(refreshID))
        }
        return RenderNode(type: "List", id: context.path, props: props, count: elements.count)
    }
}

// MARK: - Refreshable

public struct _RefreshableView<Content: View>: View {
    internal let action: @Sendable () async -> Void
    internal let content: Content
    public typealias Body = Never
}

extension _RefreshableView: _ResolutionEffectView {
    public func _applyEffect(_ context: inout ResolveContext) -> any View {
        // attach the refresh action to the List the content resolves to
        if context.refreshSink == nil { context.refreshSink = RefreshSink() }
        context.refreshSink?.action = action
        return content
    }
}

public extension View {
    func refreshable(action: @escaping @Sendable () async -> Void) -> _RefreshableView<Self> {
        _RefreshableView(action: action, content: self)
    }
}
