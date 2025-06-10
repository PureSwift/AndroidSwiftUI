//
//  AndroidImageButton.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

public struct AndroidImageButton {
    
    public typealias Label = Image
    
    let label: Label
    
    let action: () -> ()
}

public extension AndroidImageButton {
    
    init(
      action: @escaping () -> (),
      @ViewBuilder label: () -> Label
    ) {
      self.label = label()
      self.action = action
    }
}

extension AndroidImageButton: AndroidViewRepresentable {
    
    public typealias Coordinator = Void
    
    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> AndroidWidget.ImageButton {
        let view = AndroidWidget.ImageButton(context.androidContext)
        updateView(view)
        return view
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: AndroidWidget.ImageButton, context: Self.Context) {
        updateView(view)
    }
}

extension AndroidImageButton {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.ImageButton {
        let view = AndroidWidget.ImageButton(context)
        updateView(view)
        // set on click listener
        let listener = ViewOnClickListener(action: action)
        view.setClickable(true)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
        return view
    }
    
    func updateView(_ view: AndroidWidget.ImageButton) {
        // update label
        self.label.updateImageView(view)
    }
}
