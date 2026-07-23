//
//  ComposableView.swift
//  AndroidSwiftUICore
//
//  The library's escape hatch for custom platform UI — the counterpart to
//  UIKit's `UIViewRepresentable`. Because a `@Composable` (or an Android
//  `View`) can never be authored in Swift, the seam is a *named registry*:
//  Kotlin registers `name → composable` factories once at startup, and this
//  view references one by name, forwarding typed props and an optional slot of
//  SwiftUI child content.
//
//  Kotlin side:
//
//      ComposableRegistry.register("RatingBar") { props, _ ->
//          AndroidView(factory = { RatingBar(it) }, update = {
//              it.rating = (props["rating"] as? JsonPrimitive)?.floatOrNull ?: 0f
//          })
//      }
//
//  Swift side:
//
//      ComposableView("RatingBar", props: ["rating": 3.5, "max": 5])
//
//  A factory that wraps an Android-only `View` (maps, WebView, an ad SDK) uses
//  Compose's own `AndroidView` inside the registered composable — so arbitrary
//  custom Android views compose into a SwiftUI tree. An unregistered name
//  renders a visible diagnostic rather than failing silently.
//

/// A callback a custom composable can invoke to send an event back to Swift —
/// the counterpart to a `UIViewRepresentable`'s coordinator. The associated
/// value's type matches the fixed bridge dispatch surface.
public enum ComposableAction {
    case void(() -> Void)
    case bool((Bool) -> Void)
    case double((Double) -> Void)
    case int((Int) -> Void)
    case string((String) -> Void)

    internal func register(in callbacks: CallbackRegistry) -> Int64 {
        switch self {
        case .void(let action): return callbacks.register(.void(action))
        case .bool(let action): return callbacks.register(.bool(action))
        case .double(let action): return callbacks.register(.double(action))
        case .int(let action): return callbacks.register(.int(action))
        case .string(let action): return callbacks.register(.string(action))
        }
    }
}

public struct ComposableView<Content: View>: View {

    internal let name: String
    internal let props: [String: PropValue]
    internal let actions: [String: ComposableAction]
    internal let content: Content

    public init(
        _ name: String,
        props: [String: PropValue] = [:],
        actions: [String: ComposableAction] = [:],
        @ViewBuilder content: () -> Content
    ) {
        self.name = name
        self.props = props
        self.actions = actions
        self.content = content()
    }

    public typealias Body = Never
}

public extension ComposableView where Content == EmptyView {
    init(_ name: String, props: [String: PropValue] = [:], actions: [String: ComposableAction] = [:]) {
        self.init(name, props: props, actions: actions) { EmptyView() }
    }
}

extension ComposableView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props = self.props
        props["name"] = .string(name)   // reserved: identifies the registered factory
        // Each action registers a callback; its id crosses as a prop the factory
        // reads back as a typed lambda.
        for (key, action) in actions {
            props[key] = .int(Int(action.register(in: context.callbacks)))
        }
        return RenderNode(
            type: "Composable",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}
