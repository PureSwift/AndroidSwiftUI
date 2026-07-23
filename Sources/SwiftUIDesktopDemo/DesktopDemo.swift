//
//  DesktopDemo.swift
//  SwiftUIDesktopDemo
//
//  The desktop rig's Swift entry: a counter view evaluated by the core and
//  pushed through the bridge into the rig's Compose window.
//

import Foundation
import AndroidSwiftUICore
import AndroidSwiftUIBridge
import SwiftJava

@JavaClass("com.pureswift.swiftui.desktop.SwiftRuntime")
open class SwiftRuntime: JavaObject {
}

@JavaImplementation("com.pureswift.swiftui.desktop.SwiftRuntime")
extension SwiftRuntime {

    @JavaMethod
    func start(_ store: TreeStore?) {
        guard let store else { return }
        // marshal re-renders onto the main thread; async state (e.g. a List
        // refresh Task) writes off-thread and JNI object creation must run here
        let runtime = BridgeRuntime(root: ContentView(), store: store) { block in
            DispatchQueue.main.async { block() }
        }
        runtime.start()
    }
}
