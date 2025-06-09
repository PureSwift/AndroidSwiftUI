//
//  AndroidText.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

extension Text: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createView(context: context)
    }
    
    func updateAndroidView() {
        
    }
    
    func removeAndroidView() {
        
    }
}

extension Text {
    
    func createView(context: AndroidContent.Context) -> TextView {
        let view = TextView()
        updateView(view)
        return view
    }
    
    func updateView(_ view: TextView) {
        let proxy = _TextProxy(self)
        // set text
        let rawText = proxy.rawText
        view.setText(JavaString(rawText).as(CharSequence.self))
        // collect modifiers
        var color = Color.primary
        for modifier in proxy.modifiers {
            switch modifier {
            case .color(let value):
                if let value {
                    color = value
                }
            case .font(let font):
                break
            case .italic:
                break
            case .weight(let weight):
                break
            case .kerning(let kerning):
                break
            case .tracking(let tracking):
                break
            case .baseline(let baseline):
                break
            case .rounded:
                break
            case .strikethrough(let bool, let color):
                break
            case .underline(let bool, let color):
                break
            }
        }
        // set new state
        view.setTextColor(color, in: environment)
    }
    
}

internal extension TextView {
    
    /// Configure the Android Text View with the specified SwiftUI Color
    func setTextColor(
        _ color: Color,
        in environment: EnvironmentValues = .defaultEnvironment
    ) {
        let bitmask = color.argbBitMask(in: environment)
        setTextColor(Int32(bitmask))
    }
}
