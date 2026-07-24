package com.pureswift.swiftui

import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.URL

// Asset images come from the app's drawable resources, looked up by name —
// the Android analog of an asset-catalog image.
@Composable
internal actual fun rememberAssetPainter(name: String): Painter? {
    val context = LocalContext.current
    val id = remember(name) {
        context.resources.getIdentifier(name, "drawable", context.packageName)
    }
    return if (id != 0) painterResource(id) else null
}

internal actual suspend fun loadRemoteImage(url: String): ImageBitmap? =
    withContext(Dispatchers.IO) {
        runCatching {
            val bytes = fetchImageBytes(url)
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.asImageBitmap()
        }.getOrNull()
    }
