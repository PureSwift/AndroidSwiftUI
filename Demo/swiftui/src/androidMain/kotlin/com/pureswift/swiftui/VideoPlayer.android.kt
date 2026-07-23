package com.pureswift.swiftui

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.unit.dp
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView

/// Hosts a Media3 player with its standard controls. The player prepares
/// paused on the first frame; the user starts playback from the controls.
@Composable
internal actual fun RenderVideoPlayer(node: ViewNode) {
    val url = node.string("url") ?: return
    val context = LocalContext.current
    val player = remember(node.id, url) {
        ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(url))
            playWhenReady = false
            prepare()
        }
    }
    DisposableEffect(node.id, url) {
        onDispose { player.release() }
    }
    AndroidView(
        factory = { PlayerView(it).apply { this.player = player } },
        modifier = node.composeModifiers().fillMaxWidth().height(220.dp),
    )
}
