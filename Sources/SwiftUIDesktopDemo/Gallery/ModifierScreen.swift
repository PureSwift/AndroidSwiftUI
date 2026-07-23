import AndroidSwiftUICore

/// Layout and effect modifiers.
struct ModifierScreen: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ModifierSection(title: "Padding") {
                    Text("Padded")
                        .padding()
                        .background(Color.blue)
                }
                ModifierSection(title: "Frame") {
                    Text("Fixed 200x60")
                        .frame(width: 200, height: 60)
                        .background(Color.green)
                }
                ModifierSection(title: "Background") {
                    Text("Colored background")
                        .padding()
                        .background(Color.orange)
                }
                ModifierSection(title: "Clip + corner radius") {
                    Text("Rounded")
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(16)
                }
                ModifierSection(title: "Offset") {
                    Text("Shifted")
                        .offset(x: 30, y: 0)
                        .background(Color.red)
                }
                ModifierSection(title: "Rotation") {
                    Text("Rotated")
                        .background(Color.yellow)
                        .rotationEffect(.degrees(15))
                }
                ModifierSection(title: "Scale") {
                    Text("Scaled")
                        .background(Color.pink)
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

struct ModifierSection<Content: View>: View {

    let title: String

    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
            content
            Divider()
        }
    }
}
