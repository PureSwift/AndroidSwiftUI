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
        return AnyView(AndroidNavigationContainer(context: proxy.context, currentView: proxy.currentView))
    }
}

/// Native container for `NavigationView` and `NavigationStack`. Hosts the currently visible screen
/// (root content or the top of the navigation stack) as a mounted child, and intercepts the system
/// back button to pop.
struct AndroidNavigationContainer {

    /// The navigation state shared with the `NavigationLink`s of the hosted screen.
    let context: NavigationContext

    /// The screen to display, provided by the container's proxy.
    let currentView: AnyView
}

extension AndroidNavigationContainer: ParentView {

    var children: [AnyView] {
        [currentView]
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
        view.setBackHandlerEnabled(!context.path.isEmpty)
    }
}
