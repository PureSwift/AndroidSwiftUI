//
//  AndroidDivider.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension Divider: AnyAndroidView {

    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view = AndroidView.View(context)
        // hairline separator
        let matchParent = try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
        view.setLayoutParams(ViewGroup.LayoutParams(matchParent, 2))
        view.setBackgroundColor(0x33_00_00_00) // ARGB translucent black
        return view
    }

    public func updateAndroidView(_ view: AndroidView.View) {

    }

    public func removeAndroidView() {

    }
}
