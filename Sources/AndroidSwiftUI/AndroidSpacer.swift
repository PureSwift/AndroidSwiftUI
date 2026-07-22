//
//  AndroidSpacer.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

/// An Android view that expands to fill the remaining space along its parent stack's axis.
///
/// The renderer assigns weighted layout parameters when a conforming view is added to a
/// `LinearLayout`, so the view grows to absorb the leftover space.
protocol AndroidExpandingView { }

extension Spacer: AnyAndroidView, AndroidExpandingView {

    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view = AndroidView.View(context)
        // the renderer applies weighted layout parameters inside stacks; the minimum
        // dimensions preserve `minLength` in either axis
        let length = Int32(minLength ?? 0)
        view.setMinimumWidth(length)
        view.setMinimumHeight(length)
        return view
    }

    public func updateAndroidView(_ view: AndroidView.View) {

    }

    public func removeAndroidView() {

    }
}
