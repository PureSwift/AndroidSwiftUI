#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
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
