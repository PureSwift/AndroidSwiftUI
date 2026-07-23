//
//  Navigation.swift
//  AndroidSwiftUICore
//
//  Swift owns the navigation stack. Links push, `dismiss` pops, and the stack
//  emits every screen (root + pushed) so Compose can animate between them and
//  cache the outgoing screen during a pop. The model persists across
//  re-evaluation via the stack's identity path.
//

/// The pushed navigation stack, shared with the links of the hosted screens.
public final class NavigationModel: @unchecked Sendable {

    enum Entry {
        case view(() -> any View)
        case value(AnyHashable)
    }

    var stack: [Entry] = []
    var destinations: [ObjectIdentifier: (Any) -> (any View)?] = [:]
    var onChange: (() -> Void)?

    public init() {}

    func pushView(_ content: @escaping () -> any View) {
        stack.append(.view(content))
        onChange?()
    }

    func pushValue(_ value: AnyHashable) {
        stack.append(.value(value))
        onChange?()
    }

    func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
        onChange?()
    }

    func register<V>(_ type: V.Type, _ build: @escaping (V) -> any View) {
        destinations[ObjectIdentifier(type)] = { ($0 as? V).map(build) }
    }

    func resolve(_ entry: Entry) -> (any View)? {
        switch entry {
        case .view(let content):
            return content()
        case .value(let value):
            return destinations[ObjectIdentifier(type(of: value.base))]?(value.base) ?? nil
        }
    }
}

/// A stack-based navigation container.
public struct NavigationStack<Root: View>: View {

    internal let root: Root

    public init(@ViewBuilder root: () -> Root) {
        self.root = root()
    }

    public typealias Body = Never
}

extension NavigationStack: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        let model = context.storage.persistentObject(at: context.path + ".navModel") {
            NavigationModel()
        }
        model.onChange = context.storage.onChange

        // resolve each screen with the model in scope; a per-screen title sink
        // captures its navigationTitle
        var screens: [RenderNode] = []
        var titles: [PropValue] = []

        func resolveScreen(_ view: any View, index: Int, canDismiss: Bool) {
            var childContext = context.descending("screen\(index)")
            childContext.environment.set(model)
            if canDismiss {
                childContext.environment.values.dismiss = DismissAction { model.pop() }
            }
            let sink = TitleSink()
            childContext.titleSink = sink
            screens.append(Evaluator.resolve(view, childContext))
            titles.append(.string(sink.title ?? ""))
        }

        resolveScreen(root, index: 0, canDismiss: false)
        for (offset, entry) in model.stack.enumerated() {
            let view = model.resolve(entry) ?? AnyView(EmptyView())
            resolveScreen(view, index: offset + 1, canDismiss: true)
        }

        let popID = context.callbacks.register(.void { model.pop() })
        return RenderNode(
            type: "NavStack",
            id: context.path,
            props: ["titles": .array(titles), "onPop": .int(Int(popID))],
            children: screens
        )
    }
}

/// A button that pushes a destination onto the enclosing navigation stack.
public struct NavigationLink<Label: View>: View {

    internal enum Destination {
        case view(() -> any View)
        case value(AnyHashable)
    }

    internal let destination: Destination
    internal let label: Label

    public init<V: View>(destination: V, @ViewBuilder label: () -> Label) {
        self.destination = .view { destination }
        self.label = label()
    }

    public init<P: Hashable>(value: P, @ViewBuilder label: () -> Label) {
        self.destination = .value(AnyHashable(value))
        self.label = label()
    }

    public typealias Body = Never
}

public extension NavigationLink where Label == Text {
    init<S: StringProtocol, V: View>(_ title: S, destination: V) {
        self.init(destination: destination) { Text(title) }
    }
    init<S: StringProtocol, P: Hashable>(_ title: S, value: P) {
        self.init(value: value) { Text(title) }
    }
}

extension NavigationLink: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        let model = context.environment.object(of: NavigationModel.self)
        let destination = self.destination
        let callbackID = context.callbacks.register(.void {
            switch destination {
            case .view(let content): model?.pushView(content)
            case .value(let value): model?.pushValue(value)
            }
        })
        return RenderNode(
            type: "NavigationLink",
            id: context.path,
            props: ["onTap": .int(Int(callbackID))],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}

// MARK: - Modifiers

/// Records a screen's navigation title.
public struct _NavigationTitleView<Content: View>: View {
    internal let title: String
    internal let content: Content
    public typealias Body = Never
}

extension _NavigationTitleView: _ResolutionEffectView {
    public func _applyEffect(_ context: inout ResolveContext) -> any View {
        context.titleSink?.title = title
        return content
    }
}

public extension View {
    func navigationTitle<S: StringProtocol>(_ title: S) -> _NavigationTitleView<Self> {
        _NavigationTitleView(title: String(title), content: self)
    }
}

/// Registers a value-type destination builder with the enclosing stack.
public struct _NavigationDestinationView<Content: View, D: Hashable>: View {
    internal let build: (D) -> any View
    internal let content: Content
    public typealias Body = Never
}

extension _NavigationDestinationView: _ResolutionEffectView {
    public func _applyEffect(_ context: inout ResolveContext) -> any View {
        context.environment.object(of: NavigationModel.self)?.register(D.self, build)
        return content
    }
}

public extension View {
    func navigationDestination<D: Hashable, C: View>(
        for type: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> _NavigationDestinationView<Self, D> {
        _NavigationDestinationView(build: { destination($0) }, content: self)
    }
}
