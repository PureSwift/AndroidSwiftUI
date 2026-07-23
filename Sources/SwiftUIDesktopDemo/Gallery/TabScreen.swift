import AndroidSwiftUICore

/// Tab bar with selection.
struct TabScreen: View {

    @State
    private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            VStack(spacing: 16) {
                Text("First tab")
                Button("Select third tab") {
                    selection = 2
                }
            }
            .tabItem { Text("One") }
            .tag(0)
            Text("Second tab")
                .tabItem { Text("Two") }
                .tag(1)
            Text("Third tab")
                .tabItem { Text("Three") }
                .tag(2)
        }
    }
}
