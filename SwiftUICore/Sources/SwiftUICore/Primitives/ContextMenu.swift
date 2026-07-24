//
//  ContextMenu.swift
//  SwiftUICore
//
//  A menu revealed by long-pressing a view. Like a sheet, the menu items are
//  views, so they travel as children of the wrapped content rather than through
//  a scalar modifier: `contentCount` marks how many leading children are the
//  pressable content, and the rest are the menu.
//

public struct _ContextMenuView<Content: View, MenuItems: View>: View {
    internal let content: Content
    internal let menuItems: MenuItems
    public typealias Body = Never
}

extension _ContextMenuView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let contentNodes = Evaluator.resolveChildren(content, context.descending("content"))
        let menuNodes = Evaluator.resolveChildren(menuItems, context.descending("menu"))
        return RenderNode(
            type: "ContextMenu",
            id: context.path,
            props: ["contentCount": .int(contentNodes.count)],
            children: contentNodes + menuNodes
        )
    }
}

public extension View {
    /// Adds a menu shown when the view is long-pressed.
    func contextMenu<M: View>(@ViewBuilder menuItems: () -> M) -> _ContextMenuView<Self, M> {
        _ContextMenuView(content: self, menuItems: menuItems())
    }
}
