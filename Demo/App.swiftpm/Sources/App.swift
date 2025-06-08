#if canImport(SwiftAndroidUI)
import SwiftAndroidUI
#else
import SwiftUI
#endif

#if canImport(SwiftUI)
@main
struct DemoApp { }
#else
struct DemoApp { }
#endif

extension DemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
