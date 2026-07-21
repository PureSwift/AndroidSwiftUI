//
//  AndroidNavigationView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension NavigationView: AndroidPrimitive {

    var renderedBody: AnyView {
        let proxy = _NavigationViewProxy(self)
        return AnyView(AndroidNavigationContainer(
            context: proxy.context,
            content: AnyView(proxy.content),
            pushedViews: proxy.pushedViews
        ))
    }
}

/// Native container for `NavigationView` and `NavigationStack`. Hosts the root content as an
/// always mounted child — so its state survives pushes and its `navigationDestination`
/// registrations stay live — stacks the pushed screen above it, and intercepts the system back
/// button to pop.
struct AndroidNavigationContainer {

    /// The navigation state shared with the `NavigationLink`s of the hosted screen.
    let context: NavigationContext

    /// The root content, always mounted.
    let content: AnyView

    /// The pushed screens stacked above the root, in order from bottom to top.
    let pushedViews: [AnyView]
}

extension AndroidNavigationContainer: ParentView {

    var children: [AnyView] {
        var views = [content]
        views += pushedViews.map {
            AnyView(AndroidSheetOverlay(content: $0, transition: .slide))
        }
        return views
    }
}

extension AndroidNavigationContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> BackHandlerView {
        let navigationContext = self.context
        let view = BackHandlerView(context.androidContext) {
            navigationContext.pop()
        }
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: BackHandlerView, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidNavigationContainer {

    func updateView(_ view: BackHandlerView) {
        view.setBackHandlerEnabled(context.hasPushedDestinations)
    }
}
