#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

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
