//
//  ComposeRepresentable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// A wrapper for Jetpack Compose content that you use to integrate that content into your SwiftUI view hierarchy.
///
/// Composable functions cannot be authored in Swift, so conforming types return a Java object
/// implementing the `com.pureswift.swiftandroid.ComposeContent` interface, typically written in
/// Kotlin and driven by Swift state through callbacks or an adapter (see `ComposeListView`).
/// The content is hosted in a `ComposeHostView` and recomposed on every SwiftUI update.
public protocol AndroidComposeRepresentable: AndroidSwiftUI.View, AnyAndroidView, AndroidRepresentable {

    typealias Context = AndroidRepresentableContext<Self>

    /// Creates the Java object implementing `com.pureswift.swiftandroid.ComposeContent`.
    func makeComposeContent(context: Self.Context) -> JavaObject

    /// Updates state consumed by the Compose content before it is recomposed.
    func updateComposeContent(_ view: ComposeHostView, context: Self.Context)
}

/// Contextual information about the state of the system that you use to create and update your Compose content.
public typealias AndroidComposeRepresentableContext <Representable: AndroidComposeRepresentable> = AndroidRepresentableContext<Representable>

public extension AndroidComposeRepresentable {

    func updateComposeContent(_ view: ComposeHostView, context: Self.Context) { }
}

extension AndroidComposeRepresentable {

    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let coordinator = makeCoordinator()
        let representableContext = Self.Context(coordinator: coordinator, androidContext: context)
        let content = makeComposeContent(context: representableContext)
        let view = ComposeHostView(context, content)
        RepresentableCoordinatorStorage.store(coordinator, for: view)
        return view
    }

    public func updateAndroidView(_ view: AndroidView.View) {
        guard let view = view as? ComposeHostView else {
            assertionFailure("Expected \(ComposeHostView.self), found \(view)")
            return
        }
        let context = Self.Context(coordinator: coordinator(for: view), androidContext: view.getContext())
        updateComposeContent(view, context: context)
        view.refresh()
    }

    public func removeAndroidView(_ view: AndroidView.View) {
        RepresentableCoordinatorStorage.remove(for: view)
    }
}
