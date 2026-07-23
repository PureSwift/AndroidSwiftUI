import AndroidSwiftUICore

/// Text initializers and dynamic content.
struct TextScreen: View {

    @State
    private var counter = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Plain text")
            Text(verbatim: "Verbatim text")
            Text("Interpolated counter: \(counter)")
            Button("Increment") {
                counter += 1
            }
            Divider()
            Text("Multiline text that should wrap when it becomes longer than a single line on screen")
        }
    }
}
