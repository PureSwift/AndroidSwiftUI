// Desktop test rig: runs the interpreter on the macOS JVM. R3 feeds it fixture
// trees; R4 loads the Swift dylib and drives it through the real bridge.
plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.compose.multiplatform)
}

kotlin {
    jvm()
    sourceSets {
        jvmMain.dependencies {
            implementation(project(":swiftui"))
            implementation(compose.desktop.currentOs)
            implementation(compose.material3)
        }
        jvmTest.dependencies {
            implementation(kotlin("test"))
            implementation(compose.desktop.uiTestJUnit4)
        }
    }
}

// Absolute path to the Swift-built dylib; the loader loads its sibling
// libSwiftJava.dylib first (JNI_OnLoad lives there).
val swiftLibrary = rootDir.resolve("../.build/arm64-apple-macosx/debug/libSwiftUIDesktopDemo.dylib").canonicalPath

tasks.withType<Test>().configureEach {
    systemProperty("swiftui.library", swiftLibrary)
}

compose.desktop {
    application {
        mainClass = "com.pureswift.swiftui.desktop.MainKt"
        jvmArgs += "-Dswiftui.library=$swiftLibrary"
    }
}
