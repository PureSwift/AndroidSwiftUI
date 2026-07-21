package com.pureswift.swiftandroid

import androidx.compose.runtime.Composable

// Jetpack Compose content that can be hosted in a SwiftUI view hierarchy via `ComposeHostView`.
// Implementations are written in Kotlin and driven by Swift state through callbacks or adapters.
interface ComposeContent {

    @Composable
    fun Content()
}
