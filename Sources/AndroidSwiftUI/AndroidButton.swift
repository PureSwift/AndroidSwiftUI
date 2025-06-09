//
//  AndroidButton.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension _PrimitiveButtonStyleBody {
    
    
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
        let view = AndroidWidget.Button(context.androidContext)
        updateView(view)
        return view
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
        return view
    }
    
    func updateView(_ view: AndroidWidget.Button) {
        // update label
        self.label.updateTextView(view)
        // set on click listener
        let listener = ViewOnClickListener()
        listener.action = self.action
        view.setClickable(true)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
    }
}
