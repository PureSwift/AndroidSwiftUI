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
