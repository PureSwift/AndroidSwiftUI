package com.pureswift.swiftui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.Text
import androidx.compose.ui.unit.dp

/// The desktop rig has no media stack; show a labeled placeholder.
@Composable
internal actual fun RenderVideoPlayer(node: ViewNode) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = node.composeModifiers().fillMaxWidth().height(220.dp).background(Color.Black),
    ) {
        Text("▶ ${node.string("url") ?: ""}", color = Color.White)
    }
}
