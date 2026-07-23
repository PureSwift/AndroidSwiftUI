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
    }
}

compose.desktop {
    application {
        mainClass = "com.pureswift.swiftui.desktop.MainKt"
    }
}
