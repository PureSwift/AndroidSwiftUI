package com.pureswift.swiftui

// The entire Kotlin→Swift bridge surface: five externals dispatching event
// callback ids into the Swift registry. The JNI symbol for each derives from
// the SWIFT @JavaImplementation signature — these declarations and the Swift
// counterparts in SwiftCallbackSink.swift must stay exactly in sync, and this
// class must never grow per-view methods.
class SwiftCallbackSink : CallbackSink {

    external override fun invokeVoid(id: Long)

    external override fun invokeBool(id: Long, value: Boolean)

    external override fun invokeDouble(id: Long, value: Double)

    external override fun invokeInt(id: Long, value: Int)

    external override fun invokeString(id: Long, value: String)
}
