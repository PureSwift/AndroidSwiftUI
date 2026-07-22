//
//  AndroidDivider.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension Divider: AnyAndroidView {

    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        // Material Design divider, colored with the theme's outline color
        let view = MaterialDivider(context)
        let matchParent = try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
        let wrapContent = try! JavaClass<ViewGroup.LayoutParams>().WRAP_CONTENT
        view.setLayoutParams(ViewGroup.LayoutParams(matchParent, wrapContent))
        return view
    }

    public func updateAndroidView(_ view: AndroidView.View) {

    }

    public func removeAndroidView() {

    }
}
