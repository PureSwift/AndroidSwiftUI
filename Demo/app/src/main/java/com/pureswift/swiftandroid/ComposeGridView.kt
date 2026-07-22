package com.pureswift.swiftandroid

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyHorizontalGrid
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.pureswift.swiftandroid.ui.theme.SwiftAndroidTheme

// SwiftUI `LazyVGrid`/`LazyHGrid` backed by a Jetpack Compose lazy grid, sourcing its
// cells from a Swift-implemented `GridViewAdapter`.
// `ComposeView` is final, so it's hosted as a child of this `FrameLayout` rather than subclassed.
class ComposeGridView(
    context: Context,
    private val adapter: GridViewAdapter,
    // number of fixed tracks, or zero to fit as many adaptive tracks of `minItemSize` as possible
    private val trackCount: Int,
    // minimum track size in dp, used when `trackCount` is zero
    private val minItemSize: Float,
    // spacing between cells in dp
    private val spacing: Float,
    // lays tracks out as columns of a vertical grid when true, rows of a horizontal one otherwise
    private val vertical: Boolean,
) : FrameLayout(context) {

    private var version by mutableIntStateOf(0)

    init {
        val composeView = ComposeView(context)
        composeView.setContent {
            SwiftAndroidTheme {
                val count = remember(version) { adapter.getCount() }
                val cells = if (trackCount > 0) GridCells.Fixed(trackCount) else GridCells.Adaptive(minItemSize.dp)
                val arrangement = Arrangement.spacedBy(spacing.dp)
                if (vertical) {
                    LazyVerticalGrid(columns = cells, verticalArrangement = arrangement, horizontalArrangement = arrangement) {
                        items(count) { index -> Cell(index) }
                    }
                } else {
                    LazyHorizontalGrid(rows = cells, verticalArrangement = arrangement, horizontalArrangement = arrangement) {
                        items(count) { index -> Cell(index) }
                    }
                }
            }
        }
        addView(composeView, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    @androidx.compose.runtime.Composable
    private fun Cell(index: Int) {
        AndroidView(factory = { context ->
            adapter.getView(index, this) ?: View(context)
        })
    }

    fun getAdapter(): GridViewAdapter = adapter

    fun refresh() {
        version++
    }
}
