#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Form controls and their state bindings.
struct ControlsScreen: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ToggleSection()
                Divider()
                ProgressSection()
            }
        }
    }
}

struct ToggleSection: View {

    @State
    private var isOn = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Toggle")
            Toggle("Enabled", isOn: $isOn)
            Text(isOn ? "Toggle is on" : "Toggle is off")
        }
    }
}

struct ProgressSection: View {

    @State
    private var progress = 0.25

    var body: some View {
        VStack(spacing: 8) {
            Text("Indeterminate progress")
            ProgressView()
            Divider()
            Text("Determinate progress")
            ProgressView(value: progress)
            Text("\(Int(progress * 100))%")
            Button("Advance") {
                progress = progress >= 1 ? 0 : progress + 0.25
            }
        }
    }
}
