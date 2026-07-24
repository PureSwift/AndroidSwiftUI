package com.pureswift.swiftui

import java.net.HttpURLConnection
import java.net.URL

/// Bytes for a remote image, shared by both JVM targets.
///
/// Deliberately not `URL.openStream()`: that sends the default `Java/<version>`
/// user agent, which a number of CDNs reject outright (Wikimedia answers 403),
/// and it neither follows cross-protocol redirects nor surfaces a non-200 as a
/// failure — a redirect or error page would otherwise be decoded as garbage.
internal fun fetchImageBytes(url: String): ByteArray {
    var remaining = 5
    var current = URL(url)
    while (true) {
        val connection = (current.openConnection() as HttpURLConnection).apply {
            instanceFollowRedirects = false          // handled below, so http↔https works
            connectTimeout = 15_000
            readTimeout = 15_000
            setRequestProperty("User-Agent", USER_AGENT)
            setRequestProperty("Accept", "image/*")
        }
        try {
            val code = connection.responseCode
            if (code in 300..399 && remaining-- > 0) {
                val location = connection.getHeaderField("Location")
                    ?: error("redirect with no location")
                current = URL(current, location)
                continue
            }
            if (code != HttpURLConnection.HTTP_OK) error("HTTP $code for $current")
            return connection.inputStream.use { it.readBytes() }
        } finally {
            connection.disconnect()
        }
    }
}

private const val USER_AGENT = "AndroidSwiftUI/1.0"
