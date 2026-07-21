//
//  ActivityRepresentable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// A wrapper that presents an Android activity from your SwiftUI view hierarchy.
///
/// Unlike view controllers on iOS, Android activities cannot be embedded inside another
/// view hierarchy; they are always presented full screen by the system. Mounting this view
/// starts the activity with the intent returned by `makeIntent(context:)`, similar to
/// `fullScreenCover`. Communicate with the presented activity through intent extras
/// and the coordinator.
public protocol AndroidActivityRepresentable: AndroidSwiftUI.View, AnyAndroidView, AndroidRepresentable {

    typealias Context = AndroidRepresentableContext<Self>

    /// Creates the intent used to start the activity.
    func makeIntent(context: Self.Context) -> AndroidContent.Intent
}

/// Contextual information about the state of the system that you use to create the activity intent.
public typealias AndroidActivityRepresentableContext <Representable: AndroidActivityRepresentable> = AndroidRepresentableContext<Representable>

extension AndroidActivityRepresentable {

    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let coordinator = makeCoordinator()
        let representableContext = Self.Context(coordinator: coordinator, androidContext: context)
        let intent = makeIntent(context: representableContext)
        // placeholder view occupies this position in the view hierarchy
        let placeholder = AndroidView.View(context)
        RepresentableCoordinatorStorage.store(coordinator, for: placeholder)
        context.startActivity(intent)
        return placeholder
    }

    public func updateAndroidView(_ view: AndroidView.View) {
        // the started activity is owned by the system and cannot be updated externally
    }

    public func removeAndroidView(_ view: AndroidView.View) {
        RepresentableCoordinatorStorage.remove(for: view)
    }
}
