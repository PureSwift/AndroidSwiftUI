//
//  Toolbar.swift
//  SwiftUICore
//
//  Toolbar items are views, not data, so — unlike `navigationTitle` — they can't
//  ride to the navigation chrome through the title sink. They travel as hidden
//  children of the screen node instead (the mechanism sheets and alerts use),
//  each tagged with its placement, and the interpreter lifts them into the bar.
//

/// Where a toolbar item sits in the navigation chrome.
public enum ToolbarItemPlacement: String, Sendable {
    case automatic
    case navigationBarLeading
    case navigationBarTrailing
    /// Replaces the screen's title.
    case principal
    case bottomBar
}

/// A single positioned toolbar entry.
public struct ToolbarItem<Content: View>: View {

    internal let placement: ToolbarItemPlacement
    internal let content: Content

    public init(
        placement: ToolbarItemPlacement = .automatic,
        @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.content = content()
    }

    public typealias Body = Never
}

extension ToolbarItem: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "ToolbarItem",
            id: context.path,
            props: ["placement": .string(placement.rawValue)],
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

public struct _ToolbarView<Content: View, Items: View>: View {
    internal let content: Content
    internal let items: Items
    public typealias Body = Never
}

extension _ToolbarView: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        var node = Evaluator.resolve(content, context.descending("content"))
        let resolved = Evaluator.resolveChildren(items, context.descending("toolbar"))
        for item in resolved {
            if item.type == "ToolbarItem" {
                node.children.append(item)
            } else {
                // a bare view in the builder is an automatically-placed item
                node.children.append(RenderNode(
                    type: "ToolbarItem",
                    id: item.id + "/item",
                    props: ["placement": .string(ToolbarItemPlacement.automatic.rawValue)],
                    children: [item]
                ))
            }
        }
        node.props["hasToolbar"] = .bool(true)
        return node
    }
}

public extension View {
    func toolbar<Items: View>(@ViewBuilder content: () -> Items) -> _ToolbarView<Self, Items> {
        _ToolbarView(content: self, items: content())
    }
}
