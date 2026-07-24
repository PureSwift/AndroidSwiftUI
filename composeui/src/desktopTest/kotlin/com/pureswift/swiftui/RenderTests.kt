package com.pureswift.swiftui

import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import kotlinx.serialization.json.Json
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals

/// Interpreter tests on the desktop JVM — no emulator. The JSON fixtures
/// double as the wire-format contract with the Swift core's emitted schema.
@OptIn(ExperimentalTestApi::class)
class RenderTests {

    @get:Rule
    val compose = createComposeRule()

    private fun node(json: String): ViewNode = Json.decodeFromString(json)

    @Test
    fun textRendersItsContent() {
        compose.setContent {
            Render(node("""{"type":"Text","id":"root","props":{"text":"Hello"}}"""))
        }
        compose.onNodeWithText("Hello").assertIsDisplayed()
    }

    @Test
    fun stackRendersChildrenInOrder() {
        compose.setContent {
            Render(
                node(
                    """
                    {"type":"VStack","id":"root","children":[
                      {"type":"Text","id":"root/0","props":{"text":"A"}},
                      {"type":"Text","id":"root/1","props":{"text":"B"}}
                    ]}
                    """.trimIndent()
                )
            )
        }
        compose.onNodeWithText("A").assertIsDisplayed()
        compose.onNodeWithText("B").assertIsDisplayed()
    }

    @Test
    fun buttonTapDispatchesItsCallbackId() {
        val invoked = mutableListOf<Long>()
        SwiftBridge.sink = object : CallbackSink {
            override fun invokeVoid(id: Long) { invoked += id }
            override fun invokeBool(id: Long, value: Boolean) {}
            override fun invokeDouble(id: Long, value: Double) {}
            override fun invokeInt(id: Long, value: Int) {}
            override fun invokeString(id: Long, value: String) {}
        }
        compose.setContent {
            Render(
                node(
                    """
                    {"type":"Button","id":"root","props":{"onTap":42},
                     "children":[{"type":"Text","id":"root/label","props":{"text":"Tap"}}]}
                    """.trimIndent()
                )
            )
        }
        compose.onNodeWithText("Tap").performClick()
        assertEquals(listOf(42L), invoked)
    }

    @Test
    fun toggleChangeDispatchesBoolCallback() {
        val invoked = mutableListOf<Pair<Long, Boolean>>()
        SwiftBridge.sink = object : CallbackSink {
            override fun invokeVoid(id: Long) {}
            override fun invokeBool(id: Long, value: Boolean) { invoked += id to value }
            override fun invokeDouble(id: Long, value: Double) {}
            override fun invokeInt(id: Long, value: Int) {}
            override fun invokeString(id: Long, value: String) {}
        }
        compose.setContent {
            Render(
                node(
                    """
                    {"type":"Toggle","id":"root","props":{"isOn":false,"onChange":7},
                     "children":[{"type":"Text","id":"root/label","props":{"text":"Enabled"}}]}
                    """.trimIndent()
                )
            )
        }
        compose.onNode(androidx.compose.ui.test.isToggleable()).performClick()
        assertEquals(listOf(7L to true), invoked)
    }

    @Test
    fun unknownNodeRendersDiagnosticInsteadOfCrashing() {
        compose.setContent {
            Render(node("""{"type":"Mystery","id":"root"}"""))
        }
        compose.onNodeWithText("⟨unknown node: Mystery⟩").assertIsDisplayed()
    }

    @Test
    fun treeStoreDecodesFullSchema() {
        val store = TreeStore()
        store.updateJson(
            """
            {"type":"VStack","id":"root","props":{"spacing":8.0},
             "modifiers":[{"kind":"padding","args":{"top":1.0,"leading":2.0,"bottom":3.0,"trailing":4.0}}],
             "children":[{"type":"Text","id":"root/0","props":{"text":"x"}}],
             "count":null,"itemProviderId":null}
            """.trimIndent()
        )
        val root = store.root!!
        assertEquals("VStack", root.type)
        assertEquals(8.0, root.double("spacing"))
        assertEquals("padding", root.modifiers.single().kind)
        assertEquals(1, root.children.size)
    }
}
