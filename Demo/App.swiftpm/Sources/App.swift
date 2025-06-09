#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
import AndroidKit
#else
import SwiftUI
#endif

#if canImport(SwiftUI)
@main
struct DemoApp {
    
    init() {
        Self.onAppLaunch()
    }
}
#else
struct DemoApp {
    
    init() {
        Self.onAppLaunch()
    }
}
#endif

extension DemoApp {
    
    static func onAppLaunch() {
        log("Starting SwiftUI App")
    }
}

extension DemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// App launch point
#if canImport(AndroidSwiftUI)
@_silgen_name("AndroidSwiftUIMain")
func AndroidSwiftUIMain() {
    DemoApp.log(#function)
    DemoApp.main()
}

extension DemoApp {
    
    static var logTag: String { "DemoApp" }
    
    static func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.v(Self.logTag, string)
    }
}

#else

extension DemoApp {
    
    static func log(_ message: String) {
        print(message)
    }
}

#endif
