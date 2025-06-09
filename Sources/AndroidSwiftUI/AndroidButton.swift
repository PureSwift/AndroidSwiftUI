//
//  AndroidButton.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension Button: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view: AndroidView.View
        if let button = self as? Button<Text> {
            view = button.createButtonView(context: context)
        } else if let button = self as? Button<Image> {
            view = button.createImageButtonView(context: context)
        } else {
            view = createContainerView(context: context)
        }
        // set on click listener
        let listener = ViewOnClickListener()
        listener.action = self.action
        view.setClickable(true)
        view.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
        return view
    }
    
    func updateAndroidView(_ view: AndroidView.View) {
        if let button = self as? Button<Text>,
           let view = view as? AndroidWidget.Button {
            button.updateView(view)
        } else if let button = self as? Button<Image>,
            let view = view as? AndroidWidget.ImageButton {
            button.updateView(view)
        } else if let view = view as? LinearLayout {
            self.updateContainerView(view)
        }
    }
    
    func removeAndroidView() {
        
    }
}

extension Button where Label == Text {
    
    func createButtonView(context: AndroidContent.Context) -> AndroidWidget.Button {
        let view = AndroidWidget.Button(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.Button) {
        self.label.updateTextView(view)
    }
}

extension Button where Label == Image {
    
    func createImageButtonView(context: AndroidContent.Context) -> AndroidWidget.ImageButton {
        let view = AndroidWidget.ImageButton(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.ImageButton) {
        self.label.updateImageView(view)
    }
}

extension Button {
    
    func createContainerView(context: AndroidContent.Context) -> LinearLayout {
        let view = AndroidWidget.LinearLayout(context)
        updateContainerView(view)
        return view
    }
    
    func updateContainerView(_ view: LinearLayout) {
        
    }
}
