package com.pureswift.swiftandroid

import android.util.Log

/// Loads the Swift-built `.so` so its `JNI_OnLoad` runs and the bridge's
/// `@JavaImplementation` symbols resolve. The library name defaults to the
/// demo's, but any host can pass its own — this is a reusable component.
class NativeLibrary private constructor(libraryName: String) {

    companion object {

        const val defaultLibraryName = "SwiftAndroidApp"

        @Volatile
        var shared: NativeLibrary? = null

        fun shared(libraryName: String = defaultLibraryName): NativeLibrary {
            return shared ?: synchronized(this) {
                val instance = NativeLibrary(libraryName)
                shared = instance
                return instance
            }
        }
    }

    init {
        loadNativeLibrary(libraryName)
    }

    private fun loadNativeLibrary(libraryName: String) {
        try {
            System.loadLibrary(libraryName)
        } catch (error: UnsatisfiedLinkError) {
            Log.e("NativeLibrary", "Unable to load native libraries: $error")
            return
        }
        Log.d("NativeLibrary", "Loaded Swift library")
    }
}
