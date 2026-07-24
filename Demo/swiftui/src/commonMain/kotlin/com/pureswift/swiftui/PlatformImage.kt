package com.pureswift.swiftui

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.painter.Painter

// Platform seams for image loading, mirroring the VideoPlayer pattern: the
// common interpreter stays free of platform APIs, and each target supplies
// its lookup (Android app resources) and its decoder.

/// A bundled image by name, or null when the platform can't resolve it.
@Composable
internal expect fun rememberAssetPainter(name: String): Painter?

/// Fetches and decodes a remote image off the main thread; null on failure.
internal expect suspend fun loadRemoteImage(url: String): ImageBitmap?
