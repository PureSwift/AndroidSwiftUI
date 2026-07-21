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
            pushedView: proxy.pushedView
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

    /// The pushed screen stacked above the root, if any.
    let pushedView: AnyView?
}

extension AndroidNavigationContainer: ParentView {

    var children: [AnyView] {
        var views = [content]
        if let pushedView {
            views.append(AnyView(AndroidSheetOverlay(content: pushedView)))
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
