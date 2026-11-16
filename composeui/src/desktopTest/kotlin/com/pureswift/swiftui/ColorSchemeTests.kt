package com.pureswift.swiftui

import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTextInput
import kotlinx.serialization.json.Json
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ColorSchemeTests {
    @get:Rule val compose = createComposeRule()

    private fun node(json: String): ViewNode = Json.decodeFromString(json)
    private fun preference(scheme: String) = node("""{
        "type":"Text","id":"root",
        "modifiers":[{"kind":"preferredColorScheme","args":{"colorScheme":"$scheme"}}]
    }""")

    @Test fun preferenceUsesAncestorAndVisibleScreenAndDoesNotEscapeSheet() {
        val dark = preference("dark")
        val light = preference("light")
        assertEquals(false, light.copy(children = listOf(dark)).preferredDarkTheme())
        assertEquals(true, ViewNode("NavStack", "nav", children = listOf(light, dark)).preferredDarkTheme())
        assertNull(ViewNode("VStack", "root", children = listOf(
            ViewNode("Sheet", "sheet", children = listOf(dark))
        )).preferredDarkTheme())
        assertEquals(true, ViewNode("Sheet", "sheet", children = listOf(dark)).preferredDarkTheme())
        assertNull(preference("system").preferredDarkTheme())
        assertNull(ViewNode("Text", "root", modifiers = listOf(ModifierNode("preferredColorScheme"))).preferredDarkTheme())

        val tabs = node("""{
            "type":"TabView","id":"tabs","props":{"selection":7},"children":[
                {"type":"Text","id":"hidden","modifiers":[
                    {"kind":"tag","args":{"value":"4"}},
                    {"kind":"preferredColorScheme","args":{"colorScheme":"dark"}}
                ]},
                {"type":"Text","id":"visible","modifiers":[
                    {"kind":"tag","args":{"value":"7"}},
                    {"kind":"preferredColorScheme","args":{"colorScheme":"light"}}
                ]}
            ]
        }""")
        assertEquals(false, tabs.preferredDarkTheme())
    }

    @Test fun systemAndPreferredPalettesSwitchWithoutLosingTypedInput() {
        var systemDark by mutableStateOf(false)
        var root by mutableStateOf<ViewNode?>(null)
        var surface = Color.Unspecified
        var foreground = Color.Unspecified
        compose.setContent {
            SwiftUITheme(root, systemDarkTheme = systemDark) {
                surface = MaterialTheme.colorScheme.surface
                foreground = MaterialTheme.colorScheme.onSurface
                var text by remember { mutableStateOf("") }
                BasicTextField(text, onValueChange = { text = it }, modifier = Modifier.testTag("input"))
            }
        }
        compose.onNodeWithTag("input").performTextInput("keep this draft")
        compose.runOnIdle { assertTrue(surface.luminance() > foreground.luminance()); systemDark = true }
        compose.runOnIdle { assertTrue(surface.luminance() < foreground.luminance()); root = preference("light") }
        compose.runOnIdle { assertTrue(surface.luminance() > foreground.luminance()); root = preference("dark"); systemDark = false }
        compose.runOnIdle { assertTrue(surface.luminance() < foreground.luminance()); root = null }
        compose.runOnIdle { assertTrue(surface.luminance() > foreground.luminance()) }
        compose.onNodeWithTag("input").assertTextEquals("keep this draft")
    }

    // A screen presenting a sheet, each with a probe that records the
    // palette it renders in. `screen` and `sheet` are extra modifiers.
    private var screenSurface = Color.Unspecified
    private var sheetSurface = Color.Unspecified

    private fun presenting(screen: String = "", sheet: String = ""): ViewNode {
        ComposableRegistry.register("probe.screen") { _, _ -> screenSurface = MaterialTheme.colorScheme.surface }
        ComposableRegistry.register("probe.sheet") { _, _ -> sheetSurface = MaterialTheme.colorScheme.surface }
        return node("""
            {"type":"NavStack","id":"nav","props":{"titles":["Home"]},"children":[
              {"type":"VStack","id":"screen","modifiers":[$screen],"children":[
                {"type":"Composable","id":"a","props":{"name":"probe.screen"}},
                {"type":"Sheet","id":"sheet","children":[
                  {"type":"Composable","id":"b","props":{"name":"probe.sheet"},"modifiers":[$sheet]}
                ]}
              ]}
            ]}
        """)
    }

    private fun scheme(name: String) = """{"kind":"preferredColorScheme","args":{"colorScheme":"$name"}}"""

    @Test fun aSheetKeepsTheHostsOwnPaletteWithoutSwiftUITheme() {
        // A host that themes itself, dark, with colors of its own.
        val brand = Color(0xFF102030)
        val tree = presenting()
        compose.setContent {
            MaterialTheme(colorScheme = darkColorScheme(surface = brand)) { Render(tree) }
        }
        compose.waitForIdle()
        assertEquals(brand, screenSurface)
        assertEquals(brand, sheetSurface, "the sheet keeps the presenting palette")
    }

    @Test fun aSheetThatPrefersTheOtherSchemeGetsIt() {
        val tree = presenting(sheet = scheme("dark"))
        compose.setContent {
            MaterialTheme(colorScheme = lightColorScheme()) { Render(tree) }
        }
        compose.waitForIdle()
        assertTrue(screenSurface.luminance() > 0.5f, "the screen stays light")
        assertTrue(sheetSurface.luminance() < 0.5f, "the sheet is dark")
    }

    @Test fun underSwiftUIThemeASheetFollowsThePresentingScreen() {
        // The system is dark, the screen prefers light: a sheet without a
        // preference is light too, and one that prefers dark is dark.
        val light = presenting(screen = scheme("light"))
        var root by mutableStateOf(light)
        compose.setContent {
            SwiftUITheme(root, systemDarkTheme = true) { Render(root) }
        }
        compose.waitForIdle()
        assertTrue(screenSurface.luminance() > 0.5f)
        assertTrue(sheetSurface.luminance() > 0.5f, "the sheet follows the screen")
        root = presenting(screen = scheme("light"), sheet = scheme("dark"))
        compose.waitForIdle()
        assertTrue(screenSurface.luminance() > 0.5f)
        assertTrue(sheetSurface.luminance() < 0.5f, "the sheet's own preference wins")
    }
}
