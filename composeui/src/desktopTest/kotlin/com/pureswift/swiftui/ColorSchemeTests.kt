package com.pureswift.swiftui

import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.MaterialTheme
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
}
