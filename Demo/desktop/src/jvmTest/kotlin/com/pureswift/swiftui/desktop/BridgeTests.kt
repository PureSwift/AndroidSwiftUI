package com.pureswift.swiftui.desktop

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.pureswift.swiftui.Render
import com.pureswift.swiftui.SwiftBridge
import com.pureswift.swiftui.SwiftCallbackSink
import com.pureswift.swiftui.TreeStore
import org.junit.Assume.assumeTrue
import org.junit.Rule
import org.junit.Test

/// The end-to-end bridge test: native Swift evaluates the view tree, JNI
/// materializes it into Kotlin nodes, Compose renders it, a click dispatches
/// back into Swift, Swift re-evaluates, and the UI shows the new state.
/// Runs headless on the host JVM — no emulator, no window.
class BridgeTests {

    @get:Rule
    val compose = createComposeRule()

    @Test
    fun counterRoundTripAcrossTheBridge() {
        assumeTrue("swiftui.library not set — bridge test skipped", SwiftRuntime.load())

        val store = TreeStore()
        SwiftBridge.sink = SwiftCallbackSink()
        SwiftRuntime().start(store)

        compose.setContent {
            store.root?.let { Render(it) }
        }

        // initial tree evaluated in Swift
        compose.onNodeWithText("Count: 0").assertIsDisplayed()

        // Compose click → JNI → Swift @State write → re-evaluate → new tree
        compose.onNodeWithText("Increment").performClick()
        compose.onNodeWithText("Count: 1").assertIsDisplayed()

        // and again, proving the callback registry survives re-registration
        compose.onNodeWithText("Increment").performClick()
        compose.onNodeWithText("Count: 2").assertIsDisplayed()
    }
}
