//
//  AndroidOffsetEffect.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension _OffsetEffect: AndroidViewModifier {

    public func modifyAndroidView(_ view: AndroidView.View) {
        let density = view.getContext().getResources().getDisplayMetrics().density
        view.setTranslationX(Float(offset.width) * density)
        view.setTranslationY(Float(offset.height) * density)
    }
}
