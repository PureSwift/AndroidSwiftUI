package com.pureswift.swiftui

import android.content.Context
import android.app.Activity
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.material3.Surface
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.core.view.WindowCompat
import com.pureswift.bridge.BridgeExport
import com.pureswift.swiftandroid.AndroidBridgeHost

// The Android host: one Compose island rendering the whole Swift-evaluated
// tree. Swift constructs this, hands its store to the bridge runtime, and
// installs it as the activity's content view.
class SwiftUIHostView(context: Context) : FrameLayout(context) {

    val store = TreeStore()

    init {
        SwiftBridge.sink = JextractCallbackSink()
        // Installed before Swift's `AndroidSwiftUIApp.run` builds its
        // scheduler closure, since that runs later in this same construction.
        BridgeExport.bridgeSetHost(AndroidBridgeHost())
        val composeView = ComposeView(context)
        composeView.setContent {
            val root = store.root
            SwiftUITheme(root) {
                val dark = LocalDarkTheme.current
                SideEffect {
                    (context as? Activity)?.window?.let { window ->
                        val controller = WindowCompat.getInsetsController(window, composeView)
                        controller.isAppearanceLightStatusBars = !dark
                        controller.isAppearanceLightNavigationBars = !dark
                    }
                }
                Surface(modifier = Modifier.fillMaxSize()) {
                    Box(modifier = Modifier.safeDrawingPadding()) {
                        root?.let { Render(it) }
                    }
                }
            }
        }
        addView(
            composeView,
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        )
    }
}
