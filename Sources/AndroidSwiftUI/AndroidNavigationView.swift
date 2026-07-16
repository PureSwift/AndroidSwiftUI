//
//  AndroidNavigationView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension NavigationView: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidNavigationContainer(proxy: _NavigationViewProxy(self)))
    }
}

/// Native container for `NavigationView`. Hosts the currently visible screen (root content or the
/// top of the navigation stack) as a mounted child, and intercepts the system back button to pop.
struct AndroidNavigationContainer<Content: View> {

    let proxy: _NavigationViewProxy<Content>
}

extension AndroidNavigationContainer: ParentView {

    var children: [AnyView] {
        [proxy.currentView]
    }
}

extension AndroidNavigationContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> BackHandlerView {
        let path = proxy.context
        let view = BackHandlerView(context.androidContext) {
            path.pop()
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
        view.setBackHandlerEnabled(!proxy.context.path.isEmpty)
    }
}
