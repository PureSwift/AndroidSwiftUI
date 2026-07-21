//
//  Refreshable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

/// An action that initiates a refresh operation.
///
/// Mirrors SwiftUI's `RefreshAction`, which is published through the `refresh` environment value by
/// the `refreshable(action:)` modifier.
public struct RefreshAction: Sendable {

    private let action: @Sendable () async -> ()

    public init(_ action: @escaping @Sendable () async -> ()) {
        self.action = action
    }

    public func callAsFunction() async {
        await action()
    }
}

struct RefreshActionKey: EnvironmentKey {

    static let defaultValue: RefreshAction? = nil
}

public extension EnvironmentValues {

    /// A refresh action stored in a view's environment.
    var refresh: RefreshAction? {
        get { self[RefreshActionKey.self] }
        set { self[RefreshActionKey.self] = newValue }
    }
}

public extension View {

    /// Marks this view as refreshable.
    ///
    /// The action is stored in the `refresh` environment value, exactly like SwiftUI, so views that
    /// read `@Environment(\.refresh)` behave the same on Android. `List` reads this value and
    /// performs the action with a Material pull to refresh gesture, hiding the refresh indicator
    /// once the async action completes.
    func refreshable(action: @escaping @Sendable () async -> ()) -> some View {
        environment(\.refresh, RefreshAction(action))
    }
}
