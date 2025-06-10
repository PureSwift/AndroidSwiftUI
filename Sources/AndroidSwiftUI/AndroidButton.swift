//
//  AndroidButton.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import Foundation
import AndroidKit

extension Button: AnyAndroidView {
    
    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        if let text = label as? Text {
            let button = AndroidButton(
                label: text,
                action: action
            )
            return button.createAndroidView(context)
        } else if let image = label as? Image {
            let button = AndroidImageButton(
                label: image,
                action: action
            )
            return button.createAndroidView(context)
        } else {
            let button = AndroidButton(
                label: Text("Button"),
                action: action
            )
            return button.createAndroidView(context)
        }
    }
    
    public func updateAndroidView(_ view: AndroidView.View) {
        if let text = label as? Text {
            let button = AndroidButton(
                label: text,
                action: action
            )
            button.updateAndroidView(view)
        } else if let image = label as? Image {
            let button = AndroidImageButton(
                label: image,
                action: action
            )
            button.updateAndroidView(view)
        } else {
            let button = AndroidButton(
                label: Text("Button"),
                action: action
            )
            button.updateAndroidView(view)
        }
    }
    
    public func removeAndroidView() {
        
    }
    
}

/// SwiftUI view for `android.widget.Button`
public struct AndroidButton {
    
    public typealias Label = Text
    
    let label: Label
    
    let action: () -> ()
}

public extension AndroidButton {
    
    init(
      action: @escaping () -> (),
      @ViewBuilder label: () -> Label
    ) {
      self.label = label()
      self.action = action
    }
    
    init<S>(
        _ title: S,
        action: @escaping () -> ()
    ) where S: StringProtocol {
        self.init(label: Text(title), action: action)
    }
}

extension AndroidButton: AndroidViewRepresentable {
    
    public typealias Coordinator = Void
    
    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> AndroidWidget.Button {
        createView(context: context.androidContext)
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: AndroidWidget.Button, context: Self.Context) {
        updateView(view)
    }
}

extension AndroidButton {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.Button {
        let view = AndroidWidget.Button(context)
        updateView(view)
        // set on click listener
        let listener = ViewOnClickListener(action: action)
        view.setClickable(true)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
        return view
    }
    
    func updateView(_ view: AndroidWidget.Button) {
        // update label
        self.label.updateTextView(view)
    }
}
