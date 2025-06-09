//
//  OpacityEffect.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension _OpacityEffect: AndroidViewModifier {
    
    public func modifyAndroidView(_ view: AndroidView.View) {
        view.setAlpha(Float(opacity))
    }
}
