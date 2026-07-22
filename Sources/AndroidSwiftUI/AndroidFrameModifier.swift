//
//  AndroidFrameModifier.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

extension _FrameLayout: AndroidViewModifier {

    public func modifyAndroidView(_ view: AndroidView.View) {
        guard width != nil || height != nil else { return }
        let density = view.getContext().getResources().getDisplayMetrics().density
        let wrapContent = try! JavaClass<ViewGroup.LayoutParams>().WRAP_CONTENT
        func px(_ points: CGFloat) -> Int32 {
            Int32((Float(points) * density).rounded())
        }
        let resolvedWidth = width.map(px) ?? view.getLayoutParams()?.width ?? wrapContent
        let resolvedHeight = height.map(px) ?? view.getLayoutParams()?.height ?? wrapContent
        if let params = view.getLayoutParams() {
            params.width = resolvedWidth
            params.height = resolvedHeight
            view.setLayoutParams(params)
        } else {
            view.setLayoutParams(ViewGroup.LayoutParams(resolvedWidth, resolvedHeight))
        }
    }
}
