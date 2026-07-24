package com.pureswift.swiftui

import androidx.compose.ui.graphics.ImageBitmap
import java.util.Collections

// A small process-wide cache of decoded images, keyed by URL. Without it, a
// re-keyed AsyncImage (URL change, a row scrolled off then back, a re-navigated
// screen) drops its bitmap and re-fetches over the network — the spinner flashes
// every time. A hit returns the decoded bitmap synchronously, so a URL seen
// before renders with no network and no spinner.
internal object ImageCache {

    private const val MAX_ENTRIES = 64

    // access-ordered so the least-recently-used entry is evicted first
    private val store = Collections.synchronizedMap(
        object : LinkedHashMap<String, ImageBitmap>(16, 0.75f, true) {
            override fun removeEldestEntry(eldest: Map.Entry<String, ImageBitmap>): Boolean =
                size > MAX_ENTRIES
        }
    )

    fun get(url: String): ImageBitmap? = store[url]

    fun put(url: String, bitmap: ImageBitmap) {
        store[url] = bitmap
    }
}
