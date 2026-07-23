//
//  LazyStacks.swift
//  AndroidSwiftUICore
//
//  Genuinely lazy stacks. Unlike `List`, which takes its data directly, a lazy
//  stack takes a ViewBuilder — so the laziness has to come from the `ForEach`
//  inside it. When the content is exactly one `ForEach`, its elements are
//  exposed through an item provider and resolved on demand; anything else
//  (mixed or static content) falls back to resolving children eagerly, which
//  is correct, just not lazy.
//

/// Type-erased access to a `ForEach`'s elements, so a lazy container can
/// resolve one element at a time instead of flattening them all.
internal protocol _LazyElementProvider {
    var _elementCount: Int { get }
    func _elementKey(at index: Int) -> String
    func _resolveElement(at index: Int, in context: ResolveContext) -> RenderNode
}

extension ForEach: _LazyElementProvider {

    internal var _elementCount: Int { data.count }

    private func element(at index: Int) -> Data.Element {
        data[data.index(data.startIndex, offsetBy: index)]
    }

    internal func _elementKey(at index: Int) -> String {
        identityString(id(element(at: index)))
    }

    internal func _resolveElement(at index: Int, in context: ResolveContext) -> RenderNode {
        let element = self.element(at: index)
        // keyed by identity, matching the eager path, so element @State survives
        // scrolling and reordering
        let key = "#\(identityString(id(element)))"
        return Evaluator.resolve(content(element), context.descending(key))
    }
}

/// Builds a lazy stack node, using the item-provider path when the content is a
/// single `ForEach` and falling back to eager children otherwise.
internal func _lazyStackNode<Content: View>(
    type: String,
    content: Content,
    props: [String: PropValue],
    context: ResolveContext
) -> RenderNode {
    var props = props
    guard let provider = content as? _LazyElementProvider else {
        return RenderNode(
            type: type,
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
    let storage = context.storage
    let callbacks = context.callbacks
    let environment = context.environment
    let basePath = context.path + "/content"
    let count = provider._elementCount

    let providerID = callbacks.register(.item { index in
        let elementContext = ResolveContext(
            storage: storage,
            callbacks: callbacks,
            environment: environment,
            path: basePath
        )
        return provider._resolveElement(at: index, in: elementContext)
    })
    props["itemProvider"] = .int(Int(providerID))
    props["keys"] = .array((0..<count).map { .string(provider._elementKey(at: $0)) })
    return RenderNode(type: type, id: context.path, props: props, count: count)
}

/// A vertically stacked layout that only resolves the elements in view.
public struct LazyVStack<Content: View>: View {

    internal let alignment: HorizontalAlignment
    internal let spacing: Double?
    internal let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension LazyVStack: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = ["alignment": .string(alignment.rawValue)]
        if let spacing { props["spacing"] = .double(spacing) }
        return _lazyStackNode(type: "LazyVStack", content: content, props: props, context: context)
    }
}

/// A horizontally stacked layout that only resolves the elements in view.
public struct LazyHStack<Content: View>: View {

    internal let alignment: VerticalAlignment
    internal let spacing: Double?
    internal let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension LazyHStack: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = ["alignment": .string(alignment.rawValue)]
        if let spacing { props["spacing"] = .double(spacing) }
        return _lazyStackNode(type: "LazyHStack", content: content, props: props, context: context)
    }
}
