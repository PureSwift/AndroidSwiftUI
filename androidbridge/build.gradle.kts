// Reusable Android library: the JNI host glue between a Swift-built `.so` and
// the JVM — a Swift-object box, a Swift-backed Runnable, and the native-library
// loader. Kotlin only, no Swift and no Compose. Any Android app embedding a
// swift-java runtime can depend on this.
//
// The classes stay in the `com.pureswift.swiftandroid` package because their
// JNI symbol names (Java_com_pureswift_swiftandroid_…) are matched by the
// Swift `@JavaClass` bindings; the module namespace is separate.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.pureswift.androidbridge"
    compileSdk = 35
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}
