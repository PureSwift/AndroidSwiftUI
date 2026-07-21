//
//  DismissAction.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

/// An action that dismisses the current presentation.
///
/// Mirrors SwiftUI's `DismissAction`, published through the `dismiss` environment value.
/// Presented content reads it with `@Environment(\.dismiss)` and calls it to dismiss itself:
///
///     struct SheetContent: View {
///         @Environment(\.dismiss) private var dismiss
///
///         var body: some View {
///             Button("Done") { dismiss() }
///         }
///     }
public struct DismissAction {

    let action: () -> ()

    init(_ action: @escaping () -> ()) {
        self.action = action
    }

    public func callAsFunction() {
        action()
    }
}

struct DismissActionKey: EnvironmentKey {

    static let defaultValue = DismissAction { }
}

struct IsPresentedKey: EnvironmentKey {

    static let defaultValue = false
}

public extension EnvironmentValues {

    /// An action that dismisses the current presentation, if any.
    ///
    /// The default action does nothing; presentation containers (such as sheets) replace it
    /// for their presented content.
    internal(set) var dismiss: DismissAction {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }

    /// Whether the view associated with this environment is currently presented.
    internal(set) var isPresented: Bool {
        get { self[IsPresentedKey.self] }
        set { self[IsPresentedKey.self] = newValue }
    }
}
