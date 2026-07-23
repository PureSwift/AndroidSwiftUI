package com.pureswift.swiftui

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.platform.ComposeView

// The Android host: one Compose island rendering the whole Swift-evaluated
// tree. Swift constructs this, hands its store to the bridge runtime, and
// installs it as the activity's content view.
class SwiftUIHostView(context: Context) : FrameLayout(context) {

    val store = TreeStore()

    init {
        SwiftBridge.sink = SwiftCallbackSink()
        val composeView = ComposeView(context)
        composeView.setContent {
            MaterialTheme {
                Surface {
                    store.root?.let { Render(it) }
                }
            }
        }
        addView(
            composeView,
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        )
    }
}
