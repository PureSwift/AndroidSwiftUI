package com.pureswift.swiftandroid

class Application: android.app.Application() {

    init {
        NativeLibrary.shared()
    }

    override fun onCreate() {
        super.onCreate()
        onCreateSwift()
    }

    private external fun onCreateSwift()

    override fun onTerminate() {
        super.onTerminate()
        onTerminateSwift()
    }

    private external fun onTerminateSwift()
}