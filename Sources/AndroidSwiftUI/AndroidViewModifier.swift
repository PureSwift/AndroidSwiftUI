//
//  AndroidViewModifier.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

public protocol AndroidViewModifier {
    
    func modifyAndroidView(_ view: AndroidView.View)
}
/*
extension ModifiedContent: AndroidPrimitive where Content: View {

    public var renderedBody: AnyView {
        guard let viewModifier = modifier as? AndroidViewModifier else {
            return AnyView(content)
        }
        let anyWidget: any AnyAndroidView
        if let anyView = content as? AndroidPrimitive,
           let _anyWidget = mapAnyView(
            anyView.renderedBody,
            transform: { (widget: AnyAndroidView) in widget }
           )
        {
            anyWidget = _anyWidget
        } else if let _anyWidget = content as? any AnyAndroidView {
            anyWidget = _anyWidget
        } else {
            return AnyView(content)
        }
        
    }
}
*/
