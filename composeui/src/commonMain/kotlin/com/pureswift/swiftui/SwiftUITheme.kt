package com.pureswift.swiftui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.luminance

/// Whether the palette `SwiftUITheme` resolved is dark; null in a host that
/// sets its own `MaterialTheme` and calls `Render` without `SwiftUITheme`.
internal val LocalDarkTheme = compositionLocalOf<Boolean?> { null }

// Preferences affect the enclosing presentation, not just the modified node.
// An ancestor takes precedence; sheets collect their own preferences.
internal fun ViewNode.preferredDarkTheme(): Boolean? {
    for (modifier in modifiers) {
        if (modifier.kind == "preferredColorScheme") {
            when (modifier.args.string("colorScheme")) {
                "light" -> return false
                "dark" -> return true
            }
        }
    }
    val visibleChildren = when (type) {
        "NavStack" -> listOfNotNull(children.lastOrNull())
        "TabView" -> {
            val selection = long("selection")?.toInt() ?: 0
            listOfNotNull(children.firstOrNull { tab ->
                tab.modifiers.firstOrNull { it.kind == "tag" }
                    ?.args?.string("value")?.toIntOrNull() == selection
            } ?: children.getOrNull(selection))
        }
        else -> children
    }
    for (child in visibleChildren) {
        if (child.type == "Sheet" || child.type == "Alert" || child.type == "ConfirmationDialog") continue
        child.preferredDarkTheme()?.let { return it }
    }
    return null
}

/// A host's Material palette follows the system unless Swift requests a scheme.
/// Keep the composition structure stable when switching to preserve input state.
@Composable
fun SwiftUITheme(
    root: ViewNode?,
    systemDarkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val preferred = remember(root) { root?.preferredDarkTheme() }
    val dark = preferred ?: systemDarkTheme
    MaterialTheme(colorScheme = if (dark) darkColorScheme() else lightColorScheme()) {
        CompositionLocalProvider(LocalDarkTheme provides dark, content = content)
    }
}

/// A sheet's palette: the presenting screen's, unless the sheet prefers the
/// other scheme. The presenting palette is kept as it is, so a host's own
/// colors (dynamic color, a brand palette) reach its sheets; only a sheet
/// that asks for the other scheme gets the baseline Material palette for it.
/// Like `SwiftUITheme`, the composition's structure stays the same whatever
/// the preference, so remembered state inside the sheet survives a switch.
@Composable
internal fun SheetTheme(sheet: ViewNode, content: @Composable () -> Unit) {
    val preferred = remember(sheet) { sheet.preferredDarkTheme() }
    val inherited = MaterialTheme.colorScheme
    // A host without SwiftUITheme says nothing: judge its palette by its surface.
    val presentingDark = LocalDarkTheme.current ?: (inherited.surface.luminance() < 0.5f)
    val dark = preferred ?: presentingDark
    val colors = when {
        dark == presentingDark -> inherited
        dark -> darkColorScheme()
        else -> lightColorScheme()
    }
    MaterialTheme(colorScheme = colors) {
        CompositionLocalProvider(LocalDarkTheme provides dark, content = content)
    }
}
