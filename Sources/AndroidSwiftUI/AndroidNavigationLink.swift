//
//  AndroidNavigationLink.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension NavigationLink: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidNavigationLinkContainer(proxy: _NavigationLinkProxy(self)))
    }
}

/// Native container for `NavigationLink`. Hosts the link's label as a mounted child inside a
/// clickable container that pushes the destination onto the enclosing `NavigationView`'s stack.
struct AndroidNavigationLinkContainer<Label: View, Destination: View> {

    let proxy: _NavigationLinkProxy<Label, Destination>
}

extension AndroidNavigationLinkContainer: ParentView {

    var children: [AnyView] {
        [AnyView(proxy.label)]
    }
}

extension AndroidNavigationLinkContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        let listener = ViewOnClickListener(action: { proxy.activate() })
        view.setClickable(true)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {

    }
}
