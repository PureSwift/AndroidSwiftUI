// Compose Multiplatform interpreter for the Swift-evaluated node tree.
// commonMain holds the ViewNode model and the Render() interpreter; the same
// code renders on Android and on the desktop JVM (the macOS test rig).
plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.compose.multiplatform)
    alias(libs.plugins.kotlin.serialization)
}

kotlin {
    androidTarget {
        compilations.all {
            compileTaskProvider.configure {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
                }
            }
        }
    }
    jvm("desktop")

    sourceSets {
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(libs.kotlinx.serialization.json)
        }
        androidMain.dependencies {
            // VideoPlayer: the legacy MediaPlayer stack is unreliable for
            // remote streams, so the Android player is Media3.
            implementation("androidx.media3:media3-exoplayer:1.4.1")
            implementation("androidx.media3:media3-ui:1.4.1")
        }
        // `external fun` is JVM-only; both targets are JVM, so the bridge's
        // Swift-implemented classes live in a source set they share.
        val jvmShared by creating {
            dependsOn(commonMain.get())
        }
        androidMain.get().dependsOn(jvmShared)
        val desktopMain by getting {
            dependsOn(jvmShared)
        }
        val desktopTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation(compose.desktop.currentOs)
                implementation(compose.desktop.uiTestJUnit4)
            }
        }
    }
}

android {
    namespace = "com.pureswift.swiftui"
    compileSdk = 35
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}
