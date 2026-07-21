package com.pureswift.swiftandroid

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView

// Hosts `ComposeContent` for SwiftUI views conforming to `AndroidComposeRepresentable`.
// `ComposeView` is final, so it's hosted as a child of this `FrameLayout` rather than subclassed.
class ComposeHostView(context: Context, private val content: ComposeContent) : FrameLayout(context) {

    private var version by mutableIntStateOf(0)

    init {
        val composeView = ComposeView(context)
        composeView.setContent {
            key(version) {
                content.Content()
            }
        }
        addView(composeView, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    fun getContent(): ComposeContent = content

    fun refresh() {
        version++
    }
}
