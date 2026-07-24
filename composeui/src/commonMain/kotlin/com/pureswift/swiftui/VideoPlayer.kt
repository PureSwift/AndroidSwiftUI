package com.pureswift.swiftui

import androidx.compose.runtime.Composable

/// A video player for the node's `url`. Platform-specific: Android hosts a
/// system player view with playback controls; the desktop rig shows a
/// placeholder.
@Composable
internal expect fun RenderVideoPlayer(node: ViewNode)
