//
//  Evaluator.swift
//  AndroidSwiftUICore
//
//  Walks a view value tree down to primitives, producing a RenderNode tree.
//  Adapted from ClassicUICore's Resolver: same iterative body unwrapping,
//  structural identity paths, and state re-linking — but emitting a general
//  node tree rather than iPod menu rows.
//

/// State threaded through a resolve pass: the identity path and the state
/// storage the current scope's `@State` properties reconnect to.
public struct ResolveContext {

    public let storage: StateStorage
    public let callbacks: CallbackRegistry
    public var environment: EnvironmentStorage
    /// Collects the `navigationTitle` of the screen currently being resolved.
    public var titleSink: TitleSink?
    public var path: String
    public var depth: Int

    public init(
        storage: StateStorage,
        callbacks: CallbackRegistry,
        environment: EnvironmentStorage = EnvironmentStorage(),
        titleSink: TitleSink? = nil,
        path: String = "",
        depth: Int = 0
    ) {
        self.storage = storage
        self.callbacks = callbacks
        self.environment = environment
        self.titleSink = titleSink
        self.path = path
        self.depth = depth
    }

    /// Context for a child at a structurally stable position.
    public func descending(_ component: String) -> ResolveContext {
        var context = self
        context.path += "/" + component
        context.depth += 1
        return context
    }
}

/// Type-erased access to the environment-writer wrapper.
internal protocol _AnyEnvironmentWriter {
    var _object: AnyObject { get }
    var _content: any View { get }
}

extension _EnvironmentWriterView: _AnyEnvironmentWriter {
    var _object: AnyObject { object }
    var _content: any View { content }
}

// MARK: - Primitive / dispatch protocols

/// A view that resolves directly to a node (leaf or container).
public protocol PrimitiveView {
    func _render(in context: ResolveContext) -> RenderNode
}

/// A modifier wrapper: contributes a modifier to the node its content resolves
/// to, without introducing structural identity (modifiers are identity-transparent).
public protocol _ModifierProvider {
    var _modifierNode: ModifierNode { get }
    var _modifiedContent: any View { get }
}

/// A group that flattens into a sequence of sibling nodes (TupleView, ForEach,
/// conditionals, optionals).
public protocol _GroupView {
    func _flatten(into nodes: inout [RenderNode], context: ResolveContext)
}

/// A content wrapper with a side effect during resolution (registering a
/// navigation destination, recording a title, presenting a sheet). Returns the
/// content to continue resolving, and may mutate the context.
public protocol _ResolutionEffectView {
    func _applyEffect(_ context: inout ResolveContext) -> any View
}

/// Per-screen scratchpad collecting presentation attributes declared inside a
/// screen's body — its `navigationTitle` and a sheet's `presentationDetents`.
public final class TitleSink {
    public var title: String?
    public var detents: [PresentationDetent] = []
    public init() {}
}

public enum Evaluator {

    /// Guards against a self-referential `body`.
    public static let maximumDepth = 1000

    /// Evaluates the `body` of a type-erased view.
    public static func body(of view: any View) -> any View {
        func open<V: View>(_ view: V) -> any View { view.body }
        return open(view)
    }

    /// Resolves a view to a single node, unwrapping modifiers, type erasure,
    /// and composite bodies (re-linking their `@State` on the way).
    public static func resolve(_ view: any View, _ context: ResolveContext) -> RenderNode {
        guard context.depth < maximumDepth else {
            assertionFailure("View \(type(of: view)) exceeded maximum resolve depth")
            return RenderNode(type: "EmptyView", id: context.path)
        }
        switch view {
        case let modifier as _ModifierProvider:
            // identity-transparent: resolve content at the SAME path, then prepend
            var node = resolve(modifier._modifiedContent, context)
            node.modifiers.insert(modifier._modifierNode, at: 0)
            return node
        case let effect as _ResolutionEffectView:
            var context = context
            let content = effect._applyEffect(&context)
            return resolve(content, context)
        case let primitive as PrimitiveView:
            // primitives may hold container @State (navigation stack, tab
            // selection) and read @Environment, so wire both before rendering
            context.storage.install(in: view, path: context.path)
            EnvironmentInjector.inject(context.environment, into: view)
            return primitive._render(in: context)
        case let anyView as AnyView:
            return resolve(anyView.storage, context.descending("any"))
        case let writer as _AnyEnvironmentWriter:
            var child = context.descending("env")
            child.environment.set(writer._object)
            return resolve(writer._content, child)
        default:
            let child = context.descending("\(type(of: view))")
            child.storage.install(in: view, path: child.path)
            EnvironmentInjector.inject(child.environment, into: view)
            return resolve(body(of: view), child)
        }
    }

    /// Flattens a view into a sequence of sibling nodes. Groups (TupleView,
    /// ForEach, conditionals, optionals) expand; anything else is a single node.
    public static func resolveChildren(_ view: any View, _ context: ResolveContext) -> [RenderNode] {
        var nodes = [RenderNode]()
        flatten(view, into: &nodes, context: context)
        return nodes
    }

    static func flatten(_ view: any View, into nodes: inout [RenderNode], context: ResolveContext) {
        guard context.depth < maximumDepth else {
            assertionFailure("View \(type(of: view)) exceeded maximum flatten depth")
            return
        }
        switch view {
        case is EmptyView:
            return
        case let group as _GroupView:
            group._flatten(into: &nodes, context: context)
        case let modifier as _ModifierProvider:
            var before = nodes.count
            flatten(modifier._modifiedContent, into: &nodes, context: context)
            // apply the modifier to each node the content produced
            while before < nodes.count {
                nodes[before].modifiers.insert(modifier._modifierNode, at: 0)
                before += 1
            }
        case let anyView as AnyView:
            flatten(anyView.storage, into: &nodes, context: context.descending("any"))
        case let writer as _AnyEnvironmentWriter:
            var child = context.descending("env")
            child.environment.set(writer._object)
            flatten(writer._content, into: &nodes, context: child)
        case let effect as _ResolutionEffectView:
            var context = context
            let content = effect._applyEffect(&context)
            flatten(content, into: &nodes, context: context)
        default:
            nodes.append(resolve(view, context))
        }
    }
}

// MARK: - Group conformances

extension TupleView: _GroupView {

    public func _flatten(into nodes: inout [RenderNode], context: ResolveContext) {
        let mirror = Mirror(reflecting: value)
        // A single-element TupleView isn't a tuple; Mirror reports the element.
        guard mirror.displayStyle == .tuple else {
            if let view = value as? any View {
                Evaluator.flatten(view, into: &nodes, context: context.descending("0"))
            }
            return
        }
        for (offset, child) in mirror.children.enumerated() {
            guard let view = child.value as? any View else { continue }
            Evaluator.flatten(view, into: &nodes, context: context.descending("\(offset)"))
        }
    }
}

extension _ConditionalContent: _GroupView {

    public func _flatten(into nodes: inout [RenderNode], context: ResolveContext) {
        // distinct branch components so flipping the condition resets state
        switch storage {
        case .trueContent(let view):
            Evaluator.flatten(view, into: &nodes, context: context.descending("true"))
        case .falseContent(let view):
            Evaluator.flatten(view, into: &nodes, context: context.descending("false"))
        }
    }
}

extension Optional: _GroupView where Wrapped: View {

    public func _flatten(into nodes: inout [RenderNode], context: ResolveContext) {
        guard let view = self else { return }
        Evaluator.flatten(view, into: &nodes, context: context.descending("some"))
    }
}
