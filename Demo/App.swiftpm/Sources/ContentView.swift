#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Gallery of playground screens. A picker selects the active screen; full
/// `NavigationStack`/`List` navigation returns in a later step.
struct ContentView: View {

    @State
    private var screen = "Controls"

    var body: some View {
        VStack(spacing: 0) {
            Picker("Screen", selection: $screen) {
                Text("Text").tag("Text")
                Text("Buttons").tag("Buttons")
                Text("Stacks").tag("Stacks")
                Text("State").tag("State")
                Text("Controls").tag("Controls")
                Text("Modifiers").tag("Modifiers")
                Text("Observation").tag("Observation")
            }
            Divider()
            if screen == "Text" { TextScreen() }
            if screen == "Buttons" { ButtonScreen() }
            if screen == "Stacks" { StacksScreen() }
            if screen == "State" { StateScreen() }
            if screen == "Controls" { ControlsScreen() }
            if screen == "Modifiers" { ModifierScreen() }
            if screen == "Observation" { ObservationScreen() }
        }
    }
}
