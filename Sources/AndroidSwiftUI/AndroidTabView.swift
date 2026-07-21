//
//  AndroidTabView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

extension TabView: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidTabViewContainer(proxy: _TabViewProxy(self)))
    }
}

/// Native container for `TabView`. A vertical `LinearLayout` that hosts the selected tab's content
/// above a horizontal row of tab bar buttons.
struct AndroidTabViewContainer<SelectionValue: Hashable, Content: View> {

    let proxy: _TabViewProxy<SelectionValue, Content>
}

extension AndroidTabViewContainer: ParentView {

    var children: [AnyView] {
        let items = proxy.items
        let selectedIndex = proxy.selectedIndex
        // only the selected tab's content is mounted, hidden tabs are never rendered
        let content = AndroidTabContent(content: proxy.selectedContent)
        let bar = AndroidTabBar(
            labels: items.enumerated().map { index, item in
                item.label ?? AnyView(Text("Tab \(index + 1)"))
            },
            selectedIndex: selectedIndex,
            select: { proxy.select($0) }
        )
        return [AnyView(content), AnyView(bar)]
    }
}

extension AndroidTabViewContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        view.orientation = .vertical
        view.setLayoutParams(ViewGroup.LayoutParams(.matchParent, .matchParent))
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {

    }
}

// MARK: - Content

/// Hosts the selected tab's content, filling the space left over by the tab bar.
///
/// Deliberately non-generic so that switching tabs updates this container in place (instead of
/// remounting it), which keeps the content above the tab bar in the parent `LinearLayout`.
struct AndroidTabContent {

    let content: AnyView
}

extension AndroidTabContent: ParentView {

    var children: [AnyView] {
        [content]
    }
}

extension AndroidTabContent: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        view.orientation = .vertical
        // fill the remaining vertical space
        view.setLayoutParams(LinearLayout.LayoutParams(.matchParent, 0, 1).as(ViewGroup.LayoutParams.self))
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {

    }
}

// MARK: - Tab Bar

/// The row of tab bar buttons displayed at the bottom of a `TabView`.
struct AndroidTabBar {

    let labels: [AnyView]

    let selectedIndex: Int

    let select: (Int) -> ()
}

extension AndroidTabBar: ParentView {

    var children: [AnyView] {
        labels.enumerated().map { index, label in
            AnyView(AndroidTabBarButton(
                label: label,
                isSelected: index == selectedIndex,
                action: { select(index) }
            ))
        }
    }
}

extension AndroidTabBar: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        view.orientation = .horizontal
        view.gravity = .center
        view.setLayoutParams(LinearLayout.LayoutParams(.matchParent, .wrapContent, 0).as(ViewGroup.LayoutParams.self))
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {

    }
}

/// A single tab bar button, hosting its `tabItem(_:)` label as a mounted child.
struct AndroidTabBarButton {

    let label: AnyView

    let isSelected: Bool

    let action: () -> ()
}

extension AndroidTabBarButton: ParentView {

    var children: [AnyView] {
        [label]
    }
}

extension AndroidTabBarButton: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        view.orientation = .vertical
        view.gravity = .center
        // every tab occupies an equal share of the tab bar
        view.setLayoutParams(LinearLayout.LayoutParams(0, .wrapContent, 1).as(ViewGroup.LayoutParams.self))
        view.setClickable(true)
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidTabBarButton {

    func updateView(_ view: AndroidWidget.LinearLayout) {
        // the listener captures the current selection, so it has to be replaced on every update
        let listener = ViewOnClickListener(action: action)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
        view.setAlpha(isSelected ? 1.0 : 0.5)
    }
}

// MARK: - Layout Params

internal extension Int32 {

    static var matchParent: Int32 {
        try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
    }

    static var wrapContent: Int32 {
        try! JavaClass<ViewGroup.LayoutParams>().WRAP_CONTENT
    }
}
