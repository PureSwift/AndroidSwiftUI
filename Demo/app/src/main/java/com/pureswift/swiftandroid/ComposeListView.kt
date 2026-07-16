package com.pureswift.swiftandroid

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import com.pureswift.swiftandroid.ui.theme.SwiftAndroidTheme

// SwiftUI `List` backed by a Jetpack Compose `LazyColumn`, sourcing its rows from a Swift-implemented `ListViewAdapter`.
// `ComposeView` is final, so it's hosted as a child of this `FrameLayout` rather than subclassed.
class ComposeListView(context: Context, private val adapter: ListViewAdapter) : FrameLayout(context) {

    private var version by mutableIntStateOf(0)

    init {
        val composeView = ComposeView(context)
        composeView.setContent {
            SwiftAndroidTheme {
                key(version) {
                    LazyColumn {
                        items(adapter.getCount()) { index ->
                            Text(
                                text = adapter.getItem(index) as String,
                                modifier = Modifier.padding(16.dp)
                            )
                        }
                    }
                }
            }
        }
        addView(composeView, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    fun getAdapter(): ListViewAdapter = adapter

    fun refresh() {
        version++
    }
}
