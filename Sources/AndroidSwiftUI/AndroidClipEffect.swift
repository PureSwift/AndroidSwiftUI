//
//  AndroidClipEffect.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension _ClipEffect: AndroidViewModifier {

    public func modifyAndroidView(_ view: AndroidView.View) {
        // Only rounded-rect clipping is supported (`.cornerRadius`/`.clipShape(RoundedRectangle)`
        // and `.clipShape(Rectangle)`/`.clipped()`), which covers the overwhelming majority of
        // real-world usage; `.clipShape(Circle)` and arbitrary custom `Shape`s are not yet
        // supported and have no effect.
        let density = view.getContext().getResources().getDisplayMetrics().density
        let radius: Float
        if let rounded = shape as? RoundedRectangle {
            radius = Float(max(rounded.cornerSize.width, rounded.cornerSize.height)) * density
        } else if shape is Rectangle {
            radius = 0
        } else {
            return
        }
        // A transparent drawable exists solely to give the view a shaped outline to clip
        // to; any actual background color/shape is a separate compositing layer (see
        // `_BackgroundLayout` in AndroidColor.swift) and is unaffected by this.
        let outlineShape = GradientDrawable()
        outlineShape.setCornerRadius(radius)
        outlineShape.setColor(0) // transparent
        view.setBackground(outlineShape)
        view.setOutlineProvider(try! JavaClass<ViewOutlineProvider>().BACKGROUND)
        view.setClipToOutline(true)
    }
}
