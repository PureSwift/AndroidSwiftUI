#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

// The gallery screens are restored alongside the view types they exercise as the
// Compose-backed renderer is built up.

struct ContentView: View {

    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
            Toggle("Feature flag", isOn: .constant(true))
        }
    }
}

#if canImport(AndroidSwiftUI)

/// App launch point, called from `MainActivity`.
@_silgen_name("AndroidSwiftUIMain")
func AndroidSwiftUIMain() {
    AndroidSwiftUILog("Starting SwiftUI App")
    AndroidSwiftUIApp.run(ContentView())
}

#else

@main
struct DemoApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#endif
