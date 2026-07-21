//
//  AndroidXFragmentRepresentable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// A wrapper for an AndroidX fragment (`androidx.fragment.app.Fragment`) that you use
/// to integrate that fragment into your SwiftUI view hierarchy.
///
/// The renderer hosts the fragment in a dedicated container view and manages its lifecycle
/// with the support `FragmentManager`. Requires the main activity to extend
/// `androidx.fragment.app.FragmentActivity`.
public protocol AndroidXFragmentRepresentable: AndroidSwiftUI.View, AnyAndroidXFragment, AndroidRepresentable {

    /// The type of fragment to present.
    associatedtype FragmentType: AndroidXFragment

    typealias Context = AndroidRepresentableContext<Self>

    /// Creates the fragment object and configures its initial state.
    func makeFragment(context: Self.Context) -> Self.FragmentType

    /// Updates the state of the specified fragment with new information from SwiftUI.
    func updateFragment(_ fragment: Self.FragmentType, context: Self.Context)

    /// Cleans up the presented fragment (and coordinator) in anticipation of its removal.
    static func dismantleFragment(_ fragment: Self.FragmentType, coordinator: Self.Coordinator)
}

/// Contextual information about the state of the system that you use to create and update your fragment.
public typealias AndroidXFragmentRepresentableContext <Representable: AndroidXFragmentRepresentable> = AndroidRepresentableContext<Representable>

public extension AndroidXFragmentRepresentable {

    static func dismantleFragment(_ fragment: Self.FragmentType, coordinator: Self.Coordinator) { }
}

extension AndroidXFragmentRepresentable {

    public func createAndroidXFragment(_ context: AndroidContent.Context) -> AndroidXFragment {
        let coordinator = makeCoordinator()
        let context = Self.Context(coordinator: coordinator, androidContext: context)
        let fragment = makeFragment(context: context)
        RepresentableCoordinatorStorage.store(coordinator, for: fragment)
        return fragment
    }

    public func updateAndroidXFragment(_ fragment: AndroidXFragment) {
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

    public func removeAndroidXFragment(_ fragment: AndroidXFragment) {
        guard let fragment = fragment as? Self.FragmentType else {
            assertionFailure("Expected \(FragmentType.self), found \(fragment)")
            return
        }
        Self.dismantleFragment(fragment, coordinator: coordinator(for: fragment))
        RepresentableCoordinatorStorage.remove(for: fragment)
    }
}

/// Type-erased wrapper protocol used by the renderer to mount AndroidX fragments.
public protocol AnyAndroidXFragment: _PrimitiveView {

    func createAndroidXFragment(_ context: AndroidContent.Context) -> AndroidXFragment

    func updateAndroidXFragment(_ fragment: AndroidXFragment)

    /// Called by the renderer before the fragment is removed from its container.
    func removeAndroidXFragment(_ fragment: AndroidXFragment)
}

public extension AnyAndroidXFragment {

    func removeAndroidXFragment(_ fragment: AndroidXFragment) { }
}
