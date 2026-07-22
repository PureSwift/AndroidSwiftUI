//
//  AndroidRotationEffect.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension _RotationEffect: AndroidViewModifier {

    public func modifyAndroidView(_ view: AndroidView.View) {
        // `anchor` is not yet honored; Android's default pivot (view center) matches
        // SwiftUI's default `.center` anchor, the overwhelmingly common case.
        view.setRotation(Float(angle.degrees))
    }
}
