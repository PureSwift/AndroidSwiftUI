#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Gallery of playground screens, navigated with a `NavigationStack`. Each row
/// pushes a feature screen; `List`-based navigation returns with lazy
/// containers in the next step.
struct ContentView: View {

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink("Text", destination: TextScreen())
                    NavigationLink("Buttons", destination: ButtonScreen())
                    NavigationLink("Stacks", destination: StacksScreen())
                    NavigationLink("State", destination: StateScreen())
                    NavigationLink("Controls", destination: ControlsScreen())
                    NavigationLink("Modifiers", destination: ModifierScreen())
                    NavigationLink("Observation", destination: ObservationScreen())
                    NavigationLink("Navigation", destination: NavigationScreen())
                    NavigationLink("Sheets", destination: SheetScreen())
                    NavigationLink("Tabs", destination: TabScreen())
                }
            }
            .navigationTitle("Gallery")
        }
    }
}
