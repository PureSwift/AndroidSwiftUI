#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Classic and value-based navigation, plus the dismiss environment action.
struct NavigationScreen: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Value-based navigation")
            NavigationLink("Push value 1", value: 1)
            NavigationLink(value: 2) {
                Text("Push value 2")
            }
            Divider()
            Text("Classic navigation")
            NavigationLink("Push destination view", destination: ClassicDestination())
            Divider()
            Button("Pop with dismiss") {
                dismiss()
            }
        }
        .navigationDestination(for: Int.self) { value in
            ValueDestination(value: value)
        }
    }
}

struct ValueDestination: View {

    let value: Int

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Destination for value \(value)")
            if value < 3 {
                NavigationLink("Push value \(value + 1)", value: value + 1)
            }
            Button("Pop with dismiss") {
                dismiss()
            }
        }
    }
}

struct ClassicDestination: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Classic destination")
            Button("Pop with dismiss") {
                dismiss()
            }
        }
    }
}
