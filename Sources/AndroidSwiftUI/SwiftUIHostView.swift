//
//  SwiftUIHostView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit
import JavaLang
import ComposeUI
import SwiftUICore

/// Binding for the Kotlin Compose host view.
@JavaClass("com.pureswift.swiftui.SwiftUIHostView")
open class SwiftUIHostView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(_ context: AndroidContent.Context?, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getStore() -> ComposeUI.TreeStore?
}

/// Launches a SwiftUI root view as the activity's content.
public enum AndroidSwiftUIApp {

    // retains the runtime for the activity's lifetime
    private static var runtime: BridgeRuntime?

    public static func run(_ root: any SwiftUICore.View) {
        guard let activity = MainActivity.shared else {
            assertionFailure("MainActivity not created yet")
            return
        }
        let host = SwiftUIHostView(activity as AndroidContent.Context)
        guard let store = host.getStore() else {
            assertionFailure("host view has no tree store")
            return
        }
        // Re-renders post to the main looper through a JVM `Runnable`, NOT
        // `DispatchQueue.main`. Rendering makes JNI calls (materializing the
        // `ViewNode` tree), and JNI `FindClass` resolves against the class loader
        // of the Java frame on the stack. A `Runnable.run()` invocation carries
        // the app's class loader; the dispatch main-queue drain runs in a native
        // context whose fallback boot class loader can't see the app's classes,
        // so JNI aborts with `NoClassDefFoundError`. `AndroidMainActor`/
        // `DispatchQueue.main` (bound at launch) remain correct for non-JNI work.
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
