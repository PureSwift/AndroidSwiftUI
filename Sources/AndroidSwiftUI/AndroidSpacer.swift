//
//  AndroidSpacer.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension Spacer: AnyAndroidView {

    // NOTE: does not yet flex-grow to fill remaining space in its parent stack (that would require
    // AndroidRenderer's generic `addView` mounting to apply per-child LayoutParams, e.g. `layout_weight`,
    // which it doesn't do today). Rendered as a minimal-size placeholder so layouts that include a
    // `Spacer()` (e.g. List's internal row padding) still mount without crashing.
    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view = AndroidView.View(context)
        let length = Int32(minLength ?? 0)
        view.setLayoutParams(ViewGroup.LayoutParams(length, length))
        return view
    }

    public func updateAndroidView(_ view: AndroidView.View) {

    }

    public func removeAndroidView() {

    }
}
