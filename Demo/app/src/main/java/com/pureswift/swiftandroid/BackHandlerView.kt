package com.pureswift.swiftandroid

import android.content.Context
import android.widget.FrameLayout
import androidx.activity.compose.BackHandler
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView

// Hosts a Jetpack Compose `BackHandler` to intercept the system back button and forward it to
// Swift via `onBack()`. Renders no visible UI of its own; used only for its back-press interception.
class BackHandlerView(context: Context, val callback: SwiftObject) : FrameLayout(context) {

    private var handlerEnabled by mutableStateOf(true)

    init {
        val composeView = ComposeView(context)
        composeView.setContent {
            BackHandler(enabled = handlerEnabled) {
                onBack()
            }
        }
        addView(composeView)
    }

    fun setBackHandlerEnabled(value: Boolean) {
        handlerEnabled = value
    }

    external fun onBack()
}
