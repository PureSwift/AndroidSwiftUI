//
//  DesktopDemo.swift
//  SwiftUIDesktopDemo
//
//  The desktop rig's Swift entry: a counter view evaluated by the core and
//  pushed through the bridge into the rig's Compose window.
//

import AndroidSwiftUICore
import AndroidSwiftUIBridge
import SwiftJava

struct CounterDemo: View {

    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
            Toggle("Feature flag", isOn: .constant(true))
        }
    }
}

@JavaClass("com.pureswift.swiftui.desktop.SwiftRuntime")
open class SwiftRuntime: JavaObject {
}

@JavaImplementation("com.pureswift.swiftui.desktop.SwiftRuntime")
extension SwiftRuntime {

    @JavaMethod
    func start(_ store: TreeStore?) {
        guard let store else { return }
        let runtime = BridgeRuntime(root: CounterDemo(), store: store)
        runtime.start()
    }
}
