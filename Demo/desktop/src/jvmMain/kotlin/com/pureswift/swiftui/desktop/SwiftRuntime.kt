package com.pureswift.swiftui.desktop

import com.pureswift.swiftui.TreeStore

// Entry point into the Swift dylib on the desktop JVM. Loading the library
// fires swift-java's JNI_OnLoad; `start` hands Swift the tree store, and the
// Swift side evaluates its root view and drives the store from then on.
class SwiftRuntime {

    external fun start(store: TreeStore)

    companion object {

        /// Loads the Swift libraries from `-Dswiftui.library=<absolute path>`.
        /// swift-java's `JNI_OnLoad` lives in libSwiftJava, and the JVM only
        /// fires it for explicitly loaded libraries — so the runtime library
        /// (sibling `libSwiftJava.dylib`) loads first, then the app library.
        /// Returns false (rig falls back to fixtures) when not configured.
        fun load(): Boolean {
            val path = System.getProperty("swiftui.library") ?: return false
            val runtime = java.io.File(java.io.File(path).parentFile, "libSwiftJava.dylib")
            if (runtime.exists()) {
                System.load(runtime.absolutePath)
            }
            System.load(path)
            return true
        }
    }
}
