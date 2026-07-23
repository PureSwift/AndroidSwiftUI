import AndroidSwiftUICore

/// Button initializers and actions.
struct ButtonScreen: View {

    @State
    private var tapCount = 0

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Taps: \(tapCount)")
            Button("Title initializer") {
                tapCount += 1
            }
            Button(action: { tapCount += 1 }) {
                Text("Label closure initializer")
            }
            Button(action: { tapCount += 1 }) {
                Image("globe")
            }
            Button("Reset") {
                tapCount = 0
            }
        }
    }
}
