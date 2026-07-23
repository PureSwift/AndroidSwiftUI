//
//  SwiftUIHostView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit
import JavaLang
import AndroidSwiftUIBridge
import AndroidSwiftUICore

/// Binding for the Kotlin Compose host view.
@JavaClass("com.pureswift.swiftui.SwiftUIHostView")
open class SwiftUIHostView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(_ context: AndroidContent.Context?, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getStore() -> AndroidSwiftUIBridge.TreeStore?
}

/// Launches a SwiftUI root view as the activity's content.
public enum AndroidSwiftUIApp {

    // retains the runtime for the activity's lifetime
    private static var runtime: BridgeRuntime?

    public static func run(_ root: any AndroidSwiftUICore.View) {
        guard let activity = MainActivity.shared else {
            assertionFailure("MainActivity not created yet")
            return
        }
        let host = SwiftUIHostView(activity as AndroidContent.Context)
        guard let store = host.getStore() else {
            assertionFailure("host view has no tree store")
            return
        }
        // marshal re-renders onto the main looper: JNI object creation and
        // Compose state writes must run there, not on a Swift Task's thread
        let handler = AndroidOS.Handler(try! JavaClass<AndroidOS.Looper>().getMainLooper())
        let runtime = BridgeRuntime(root: root, store: store) { block in
            let runnable = Runnable { block() }
            _ = handler.post(runnable.as(JavaLang.Runnable.self))
        }
        Self.runtime = runtime
        runtime.start()
        activity.setRootView(host)
    }
}
