//
//  TabView.swift
//  SwiftUICore
//
//  A tab container. Each child contributes a tab: its `.tabItem` label and its
//  `.tag` selection value. Swift owns the selection binding; the interpreter
//  renders a bottom bar and shows the selected tab's content.
//

/// A tabbed container with an integer selection binding.
public struct TabView<Content: View>: View {

    internal let selection: Binding<Int>
    internal let content: Content

    public init(selection: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.selection = selection
        self.content = content()
    }

    public typealias Body = Never
}

extension TabView: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        // each child flattens to one node carrying its tabItem/tag as modifiers
        let tabs = Evaluator.resolveChildren(content, context.descending("content"))
        let binding = selection
        let selectID = context.callbacks.register(.int { binding.wrappedValue = $0 })
        return RenderNode(
            type: "TabView",
            id: context.path,
            props: ["selection": .int(selection.wrappedValue), "onSelect": .int(Int(selectID))],
            children: tabs
        )
    }
}

/// Sets a tab's bar label. The label's text is captured for the bar.
public struct _TabItemView<Content: View, Label: View>: View {
    internal let label: Label
    internal let content: Content
    public typealias Body = Never
}

extension _TabItemView: _ModifierProvider {
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "tabItem", args: ["text": .string(firstText(in: label) ?? "")])
    }
    public var _modifiedContent: any View { content }
}

public extension View {
    func tabItem<L: View>(@ViewBuilder _ label: () -> L) -> _TabItemView<Self, L> {
        _TabItemView(label: label(), content: self)
    }
}

// A tab's selection value uses the same `.tag(_:)` as Picker (string-encoded);
// TabView parses it back to Int.

/// Extracts the first `Text` string from a small label view tree, for bar labels.
internal func firstText(in view: Any, depth: Int = 0) -> String? {
    if depth > 8 { return nil }
    if let text = view as? Text { return text.content }
    for child in Mirror(reflecting: view).children {
        if let found = firstText(in: child.value, depth: depth + 1) {
            return found
        }
    }
    return nil
}
