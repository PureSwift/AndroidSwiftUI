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

public struct ComposableView<Content: View>: View {

    internal let name: String
    internal let props: [String: PropValue]
    internal let content: Content

    public init(_ name: String, props: [String: PropValue] = [:], @ViewBuilder content: () -> Content) {
        self.name = name
        self.props = props
        self.content = content()
    }

    public typealias Body = Never
}

public extension ComposableView where Content == EmptyView {
    init(_ name: String, props: [String: PropValue] = [:]) {
        self.init(name, props: props) { EmptyView() }
    }
}

extension ComposableView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props = self.props
        props["name"] = .string(name)   // reserved: identifies the registered factory
        return RenderNode(
            type: "Composable",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}
