package com.pureswift.swiftui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.getUnclippedBoundsInRoot
import androidx.compose.ui.test.hasClickAction
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import kotlinx.serialization.json.Json
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals

/// Grid, swipe actions, and what TalkBack gets from images, context menus
/// and registered views.
@OptIn(ExperimentalTestApi::class)
class AppleLayoutsTests {

    @get:Rule
    val compose = createComposeRule()

    private fun node(json: String): ViewNode = Json.decodeFromString(json)

    private val tapped = mutableListOf<Long>()

    private fun recordTaps() {
        SwiftBridge.sink = object : CallbackSink {
            override fun invokeVoid(id: Long) { tapped += id }
            override fun invokeBool(id: Long, value: Boolean) {}
            override fun invokeDouble(id: Long, value: Double) {}
            override fun invokeInt(id: Long, value: Int) {}
            override fun invokeString(id: Long, value: String) {}
        }
    }

    private fun text(id: String, text: String, tag: String) =
        """{"type":"Text","id":"$id","props":{"text":"$text"},"modifiers":[{"kind":"accessibilityIdentifier","args":{"id":"$tag"}}]}"""

    @Test
    fun gridSizesEachColumnToItsWidestCell() {
        compose.setContent {
            Render(node("""
                {"type":"Grid","id":"g","props":{"horizontalSpacing":10.0,"verticalSpacing":4.0,"horizontal":"leading"},"children":[
                  {"type":"GridRow","id":"r0","children":[${text("a", "Short", "a")},${text("b", "B", "b")}]},
                  {"type":"GridRow","id":"r1","children":[${text("c", "A much longer cell", "c")},${text("d", "D", "d")}]}
                ]}
            """.trimIndent()))
        }
        val a = compose.onNodeWithTag("a").getUnclippedBoundsInRoot()
        val b = compose.onNodeWithTag("b").getUnclippedBoundsInRoot()
        val c = compose.onNodeWithTag("c").getUnclippedBoundsInRoot()
        val d = compose.onNodeWithTag("d").getUnclippedBoundsInRoot()
        assertEquals(a.left, c.left, "the first column's cells line up")
        assertEquals(b.left, d.left, "the second column starts after the widest first cell")
        assertEquals(c.right + 10.dp, d.left)
        assertEquals(a.bottom + 4.dp, c.top)
    }

    @Test
    fun aFlexibleViewTakesTheSpaceItsSiblingsLeave() {
        ComposableRegistry.register("test.Fills") { _, _ ->
            Box(Modifier.fillMaxSize().testTag("fills"))
        }
        fun stack(frame: String) = """
            {"type":"VStack","id":"s","props":{"spacing":0.0},"modifiers":[{"kind":"frame","args":{"height":300.0}}],"children":[
              ${text("a", "Above", "above")},
              {"type":"Composable","id":"f","props":{"name":"test.Fills","flexible":true}$frame},
              ${text("b", "Below", "below")}
            ]}
        """.trimIndent()
        var json by mutableStateOf(stack(""))
        compose.setContent { Render(node(json)) }
        val above = compose.onNodeWithTag("above").getUnclippedBoundsInRoot()
        val fills = compose.onNodeWithTag("fills").getUnclippedBoundsInRoot()
        val below = compose.onNodeWithTag("below").getUnclippedBoundsInRoot()
        assertEquals(above.bottom, fills.top)
        assertEquals(fills.bottom, below.top, "the text after it still shows")
        assertEquals(300.dp, below.bottom, "it takes the rest of the stack")
        // A fixed height wins.
        json = stack(""","modifiers":[{"kind":"frame","args":{"height":50.0}}]""")
        compose.waitForIdle()
        assertEquals(50.dp, compose.onNodeWithTag("fills").getUnclippedBoundsInRoot().let { it.bottom - it.top })
    }

    @Test
    fun swipeActionsAreTheRowsTalkBackActions() {
        recordTaps()
        compose.setContent {
            Render(node("""
                {"type":"SwipeActions","id":"s","props":{"edge":"trailing"},"children":[
                  {"type":"Text","id":"row","props":{"text":"Banana"}},
                  {"type":"Button","id":"delete","props":{"onTap":5,"role":"destructive"},
                   "children":[{"type":"Text","id":"delete/label","props":{"text":"Delete"}}]}
                ]}
            """.trimIndent()))
        }
        compose.onNodeWithText("Delete").assertDoesNotExist()
        val row = compose.onNode(SemanticsMatcher.keyIsDefined(SemanticsActions.CustomActions)).fetchSemanticsNode()
        val actions = row.config[SemanticsActions.CustomActions]
        assertEquals(listOf("Delete"), actions.map { it.label })
        compose.runOnIdle { actions.single().action() }
        assertEquals(listOf(5L), tapped)
    }

    @Test
    fun contextMenusAddNoSecondClickableNode() {
        recordTaps()
        compose.setContent {
            Render(node("""
                {"type":"ContextMenu","id":"m","props":{"contentCount":1},"children":[
                  {"type":"Button","id":"open","props":{"onTap":1},"children":[{"type":"Text","id":"open/t","props":{"text":"Apple"}}]},
                  {"type":"Button","id":"like","props":{"onTap":2},"children":[{"type":"Text","id":"like/t","props":{"text":"Like"}}]}
                ]}
            """.trimIndent()))
        }
        compose.onAllNodes(hasClickAction()).assertCountEquals(1)
        val menu = compose.onNode(SemanticsMatcher.keyIsDefined(SemanticsActions.CustomActions)).fetchSemanticsNode()
        val actions = menu.config[SemanticsActions.CustomActions]
        assertEquals(listOf("Like"), actions.map { it.label })
        compose.runOnIdle { actions.single().action() }
        assertEquals(listOf(2L), tapped)
    }

    @Test
    fun imagesSayTheirLabelOnce() {
        compose.setContent {
            Render(node("""
                {"type":"VStack","id":"v","children":[
                  {"type":"Image","id":"i0","props":{"systemName":"star","label":"Favorite"}},
                  {"type":"Image","id":"i1","props":{"systemName":"star"},
                   "modifiers":[{"kind":"accessibilityLabel","args":{"text":"Gold star"}}]}
                ]}
            """.trimIndent()))
        }
        compose.onAllNodesWithContentDescription("Favorite").assertCountEquals(1)
        val labeled = compose.onAllNodesWithContentDescription("Gold star").fetchSemanticsNodes().single()
        assertEquals(listOf("Gold star"), labeled.config[SemanticsProperties.ContentDescription])
    }

    @Test
    fun registeredViewsGetTheirModifiers() {
        ComposableRegistry.register("test.greeting") { _, _ -> Text("Hi") }
        compose.setContent {
            Render(node("""
                {"type":"Composable","id":"c","props":{"name":"test.greeting"},
                 "modifiers":[{"kind":"accessibilityIdentifier","args":{"id":"greeting"}},
                              {"kind":"padding","args":{"top":20.0,"leading":0.0,"bottom":0.0,"trailing":0.0}}]}
            """.trimIndent()))
        }
        val box = compose.onNodeWithTag("greeting").getUnclippedBoundsInRoot()
        val text = compose.onNodeWithText("Hi").getUnclippedBoundsInRoot()
        assertEquals(box.top + 20.dp, text.top, "the padding wraps the registered view")
    }
}
