//
//  AndroidNavigationStack.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

extension NavigationStack: AndroidPrimitive {

    var renderedBody: AnyView {
        let proxy = _NavigationStackProxy(self)
        return AnyView(AndroidNavigationContainer(
            context: proxy.context,
            content: AnyView(proxy.content),
            pushedViews: proxy.pushedViews
        ))
    }
}
