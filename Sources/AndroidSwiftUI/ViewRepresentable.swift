//
//  ViewRepresentable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

/// A wrapper for an Android view that you use to integrate that view into your SwiftUI view hierarchy.
public protocol AndroidViewRepresentable: AndroidSwiftUI.View, AnyAndroidView {
    
    /// The type of view to present.
    associatedtype AndroidViewType: AndroidView.View
    
    associatedtype Coordinator
    
    typealias Context = AndroidViewRepresentableContext<Self>
    
    /// Creates the view object and configures its initial state.
    func makeAndroidView(context: Self.Context) -> Self.AndroidViewType
    
    /// Updates the state of the specified view with new information from SwiftUI.
    func updateAndroidView(_ view: Self.AndroidViewType, context: Self.Context)
    
    /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
    func makeCoordinator() -> Self.Coordinator
}

public extension AndroidViewRepresentable where Self.Coordinator == Void {
    
    func makeCoordinator() { }
}

/// Contextual information about the state of the system that you use to create and update your Android view.
public struct AndroidViewRepresentableContext <Content: View> {
    
    let androidContext: AndroidContent.Context
}

extension AndroidViewRepresentable where Self: AnyAndroidView {
    
    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let context = Self.Context(androidContext: context)
        let view = makeAndroidView(context: context)
        return view
    }
    
    public func updateAndroidView(_ view: AndroidView.View) {
        guard let view = view as? Self.AndroidViewType else {
            assertionFailure("Expected \(AndroidViewType.self), found \(view)")
            return
        }
        let context = Self.Context(androidContext: view.getContext())
        updateAndroidView(view, context: context)
    }
    
    public func removeAndroidView() {
        
    }
}
