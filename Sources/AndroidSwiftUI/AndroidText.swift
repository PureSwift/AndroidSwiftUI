//
//  AndroidText.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

extension Text: AnyAndroidView {
    
    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createTextView(context: context)
    }
    
    public func updateAndroidView(_ view: AndroidView.View) {
        guard let textView = view.as(TextView.self) else {
            assertionFailure()
            return
        }
        updateTextView(textView)
    }
    
    public func removeAndroidView() {
        
    }
}

extension Text {
    
    func createTextView(context: AndroidContent.Context) -> TextView {
        let view = TextView(context)
        updateTextView(view)
        return view
    }
    
    func updateTextView(_ view: TextView) {
        let proxy = _TextProxy(self)
        // set text
        let rawText = proxy.rawText
        view.text = rawText
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
        view.setTextColor(color, in: proxy.environment)
    }
    
}

internal extension TextView {
    
    /// Configure the Android Text View with the specified SwiftUI Color
    func setTextColor(
        _ color: Color,
        in environment: EnvironmentValues = .defaultEnvironment
    ) {
        let bitmask = color.argbBitMask(in: environment)
        setTextColor(Int32(bitPattern: bitmask))
    }
    
    var text: String {
        get {
            getText().toString()
        }
        set {
            setText(JavaString(newValue).as(CharSequence.self))
        }
    }
}
