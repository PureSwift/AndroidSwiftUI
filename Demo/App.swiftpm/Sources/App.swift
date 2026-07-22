#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
import AndroidKit
#else
import SwiftUI
#endif

// The gallery screens are restored alongside the view types they exercise as the
// Compose-backed renderer is built up; until then this is a bare launch point.

#if canImport(AndroidSwiftUI)

/// App launch point, called from `MainActivity`.
@_silgen_name("AndroidSwiftUIMain")
func AndroidSwiftUIMain() {
    let log = try! JavaClass<AndroidUtil.Log>()
    _ = log.v("DemoApp", "Starting SwiftUI App")
}

#else

@main
struct DemoApp: App {

    var body: some Scene {
        WindowGroup {
            Text("Demo")
        }
    }
}

#endif
