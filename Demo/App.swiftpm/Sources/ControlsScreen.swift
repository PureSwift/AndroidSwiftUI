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

    @State
    private var sliderValue = 0.5

    @State
    private var name = ""

    @State
    private var fruit = "Apple"

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
                Divider()
                Text("Slider")
                Slider(value: $sliderValue, in: 0...1)
                Text("Value: \(Int(sliderValue * 100))%")
                Divider()
                Text("Text field")
                TextField("Name", text: $name)
                Text(name.isEmpty ? "Nothing typed yet" : "Hello, \(name)")
                Divider()
                Text("Picker")
                Picker("Fruit", selection: $fruit) {
                    Text("Apple").tag("Apple")
                    Text("Banana").tag("Banana")
                    Text("Cherry").tag("Cherry")
                }
                Text("Selected: \(fruit)")
            }
        }
    }
}
