package com.pureswift.swiftui

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.graphics.toComposeImageBitmap
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// The desktop rig has no app resource bundle, so named assets don't resolve
// there (a documented desktop limit); the placeholder path renders instead.
@Composable
internal actual fun rememberAssetPainter(name: String): Painter? = null

internal actual suspend fun loadRemoteImage(url: String): ImageBitmap? =
    withContext(Dispatchers.IO) {
        runCatching {
            org.jetbrains.skia.Image.makeFromEncoded(fetchImageBytes(url)).toComposeImageBitmap()
        }.getOrNull()
    }
