//
//  FragmentRepresentable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// A wrapper for an Android fragment that you use to integrate that fragment into your SwiftUI view hierarchy.
///
/// The renderer hosts the fragment in a dedicated container view added to the view hierarchy
/// and manages its lifecycle with `FragmentManager` transactions.
public protocol AndroidFragmentRepresentable: AndroidSwiftUI.View, AnyAndroidFragment, AndroidRepresentable {

    /// The type of fragment to present.
    associatedtype FragmentType: AndroidApp.Fragment

    typealias Context = AndroidRepresentableContext<Self>

    /// Creates the fragment object and configures its initial state.
    func makeFragment(context: Self.Context) -> Self.FragmentType

    /// Updates the state of the specified fragment with new information from SwiftUI.
    func updateFragment(_ fragment: Self.FragmentType, context: Self.Context)

    /// Cleans up the presented fragment (and coordinator) in anticipation of its removal.
    static func dismantleFragment(_ fragment: Self.FragmentType, coordinator: Self.Coordinator)
}

/// Contextual information about the state of the system that you use to create and update your fragment.
public typealias AndroidFragmentRepresentableContext <Representable: AndroidFragmentRepresentable> = AndroidRepresentableContext<Representable>

public extension AndroidFragmentRepresentable {

    static func dismantleFragment(_ fragment: Self.FragmentType, coordinator: Self.Coordinator) { }
}

extension AndroidFragmentRepresentable {

    public func createFragment(_ context: AndroidContent.Context) -> AndroidApp.Fragment {
        let coordinator = makeCoordinator()
        let context = Self.Context(coordinator: coordinator, androidContext: context)
        let fragment = makeFragment(context: context)
        RepresentableCoordinatorStorage.store(coordinator, for: fragment)
        return fragment
    }

    public func updateFragment(_ fragment: AndroidApp.Fragment) {
        guard let fragment = fragment as? Self.FragmentType else {
            assertionFailure("Expected \(FragmentType.self), found \(fragment)")
            return
        }
        // the fragment is detached, no context available for updates
        guard let activity = fragment.getActivity() else {
            return
        }
        let context = Self.Context(coordinator: coordinator(for: fragment), androidContext: activity)
        updateFragment(fragment, context: context)
    }

    public func removeFragment(_ fragment: AndroidApp.Fragment) {
        guard let fragment = fragment as? Self.FragmentType else {
            assertionFailure("Expected \(FragmentType.self), found \(fragment)")
            return
        }
        Self.dismantleFragment(fragment, coordinator: coordinator(for: fragment))
        RepresentableCoordinatorStorage.remove(for: fragment)
    }
}

/// Type-erased wrapper protocol used by the renderer to mount Android fragments.
public protocol AnyAndroidFragment: _PrimitiveView {

    func createFragment(_ context: AndroidContent.Context) -> AndroidApp.Fragment

    func updateFragment(_ fragment: AndroidApp.Fragment)

    /// Called by the renderer before the fragment is removed from its container.
    func removeFragment(_ fragment: AndroidApp.Fragment)
}

public extension AnyAndroidFragment {

    func removeFragment(_ fragment: AndroidApp.Fragment) { }
}
