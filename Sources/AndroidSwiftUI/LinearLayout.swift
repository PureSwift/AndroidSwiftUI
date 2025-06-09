//
//  HStack.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

protocol LinearLayoutView: LayoutContainerView {
    
    static var layoutOrientation: LinearLayout.Orientation { get }
    
    var gravity: ViewGravity { get }
}

extension LinearLayoutView {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.LinearLayout) {
        view.orientation = Self.layoutOrientation
        view.gravity = self.gravity
    }
}

extension VStack: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createView(context: context)
    }
    
    func updateAndroidView(_ view: AndroidView.View) {
        guard let linearLayout = view.as(LinearLayout.self) else {
            assertionFailure()
            return
        }
        updateView(linearLayout)
    }
    
    func removeAndroidView() {
        
    }
}

extension VStack: LinearLayoutView {
    
    static var layoutOrientation: LinearLayout.Orientation { .vertical }
    
    var gravity: ViewGravity {
        alignment.gravity
    }
}

extension HStack: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createView(context: context)
    }

    func updateAndroidView(_ view: AndroidView.View) {
        guard let linearLayout = view.as(LinearLayout.self) else {
            assertionFailure()
            return
        }
        updateView(linearLayout)
    }
    
    func removeAndroidView() {
        
    }
}

extension HStack: LinearLayoutView {
    
    static var layoutOrientation: LinearLayout.Orientation { .horizontal }
    
    var gravity: ViewGravity {
        alignment.gravity
    }
}
