//
//  Representable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// Common requirements for wrappers that integrate Android platform components
/// (views, fragments, activities and Jetpack Compose content) into the SwiftUI view hierarchy.
public protocol AndroidRepresentable {

    /// A type to coordinate with the Android platform component.
    associatedtype Coordinator

    /// Creates the custom instance that you use to communicate changes from your
    /// Android component to other parts of your SwiftUI interface.
    func makeCoordinator() -> Coordinator
}

public extension AndroidRepresentable where Coordinator == Void {

    func makeCoordinator() { }
}

/// Contextual information about the state of the system that you use to create and update your Android component.
public struct AndroidRepresentableContext <Representable: AndroidRepresentable> {

    /// The representable's coordinator.
    public let coordinator: Representable.Coordinator

    /// The Android context of the enclosing activity.
    public let androidContext: AndroidContent.Context
}

internal extension AndroidRepresentable {

    /// Returns the retained coordinator for the specified mounted Java object,
    /// creating a new one if none was stored.
    func coordinator(for object: JavaObject) -> Coordinator {
        if let coordinator = RepresentableCoordinatorStorage.coordinator(for: object) as? Coordinator {
            return coordinator
        }
        return makeCoordinator()
    }
}

/// Retains coordinator instances for the lifetime of their mounted Java objects,
/// keyed by Java object identity.
internal enum RepresentableCoordinatorStorage {

    private static var coordinators = [Key: Any]()

    static func store<C>(_ coordinator: C, for object: JavaObject) {
        // no need to retain empty coordinators
        guard C.self != Void.self else { return }
        coordinators[Key(object)] = coordinator
    }

    static func coordinator(for object: JavaObject) -> Any? {
        coordinators[Key(object)]
    }

    static func remove(for object: JavaObject) {
        coordinators[Key(object)] = nil
    }
}

internal extension RepresentableCoordinatorStorage {

    /// Hashable wrapper using Java object equality.
    struct Key: Hashable {

        let object: JavaObject

        init(_ object: JavaObject) {
            self.object = object
        }

        static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.object.equals(rhs.object)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(object.hashCode())
        }
    }
}
