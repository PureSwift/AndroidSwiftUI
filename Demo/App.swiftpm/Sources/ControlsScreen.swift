#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Form controls and their state bindings.
struct ControlsScreen: View {

    @State
    private var isOn = false

    @State
    private var progress = 0.25

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Toggle")
                Toggle("Enabled", isOn: $isOn)
                Text(isOn ? "Toggle is on" : "Toggle is off")
                Divider()
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
}
