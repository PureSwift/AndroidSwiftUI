package com.pureswift.swiftandroid

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import com.pureswift.swiftandroid.ui.theme.SwiftAndroidTheme

// Hosts `ComposeContent` for SwiftUI views conforming to `AndroidComposeRepresentable`.
// `ComposeView` is final, so it's hosted as a child of this `FrameLayout` rather than subclassed.
class ComposeHostView(context: Context, private val content: ComposeContent) : FrameLayout(context) {

    private var version by mutableIntStateOf(0)

    init {
        val composeView = ComposeView(context)
        composeView.setContent {
            SwiftAndroidTheme {
                // Reading the version registers it as a recomposition dependency, so `refresh()`
                // recomposes the content in place (rather than recreating the composition with
                // `key`), preserving internal Compose state such as scroll positions.
                @Suppress("UNUSED_VARIABLE")
                val refresh = version
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
