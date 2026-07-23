//
//  SwiftCallbackSink.swift
//  AndroidSwiftUIBridge
//
//  The entire Kotlin→Swift bridge surface. The JNI symbol for each method
//  derives from THIS signature — the Kotlin `external` declarations in
//  SwiftCallbackSink.kt must stay exactly in sync, and this class must never
//  grow per-view methods.
//

import SwiftJava

@JavaClass("com.pureswift.swiftui.SwiftCallbackSink")
open class SwiftCallbackSink: JavaObject {
}

@JavaImplementation("com.pureswift.swiftui.SwiftCallbackSink")
extension SwiftCallbackSink {

    @JavaMethod
    func invokeVoid(_ id: Int64) {
        BridgeRuntime.current?.invokeVoid(id)
    }

    @JavaMethod
    func invokeBool(_ id: Int64, _ value: Bool) {
        BridgeRuntime.current?.invokeBool(id, value)
    }

    @JavaMethod
    func invokeDouble(_ id: Int64, _ value: Double) {
        BridgeRuntime.current?.invokeDouble(id, value)
    }

    @JavaMethod
    func invokeInt(_ id: Int64, _ value: Int32) {
        BridgeRuntime.current?.invokeInt(id, Int(value))
    }

    @JavaMethod
    func invokeString(_ id: Int64, _ value: String) {
        BridgeRuntime.current?.invokeString(id, value)
    }

    @JavaMethod
    func itemNode(_ id: Int64, _ index: Int32) -> ViewNodeObject? {
        BridgeRuntime.current?.itemNode(id, Int(index))
    }
}
