package com.pureswift.swiftui.desktop

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import com.pureswift.swiftui.Render
import com.pureswift.swiftui.TreeStore

/// Fixture trees mirroring the Swift core's emitted schema — the wire-format
/// contract exercised from the Kotlin side. R4 replaces fixtures with live
/// trees evaluated by the Swift dylib.
object Fixtures {

    val counter = """
        {"type":"VStack","id":"root","props":{"spacing":12.0},"children":[
          {"type":"Text","id":"root/content/0","props":{"text":"count 0"}},
          {"type":"Button","id":"root/content/1","props":{"onTap":1},
           "children":[{"type":"Text","id":"root/content/1/label/0","props":{"text":"Increment"}}]}
        ]}
    """.trimIndent()

    val stacks = """
        {"type":"VStack","id":"root","props":{"spacing":8.0},"children":[
          {"type":"Text","id":"root/0","props":{"text":"Padded"},
           "modifiers":[{"kind":"background","args":{"color":24919}},{"kind":"padding","args":{}}]},
          {"type":"HStack","id":"root/1","children":[
            {"type":"Text","id":"root/1/0","props":{"text":"Start"}},
            {"type":"Spacer","id":"root/1/1"},
            {"type":"Text","id":"root/1/2","props":{"text":"End"}}
          ]},
          {"type":"Divider","id":"root/2"},
          {"type":"ZStack","id":"root/3","props":{"horizontal":"trailing","vertical":"bottom"},"children":[
            {"type":"Text","id":"root/3/0","props":{"text":"BASE"},
             "modifiers":[{"kind":"frame","args":{"width":200.0,"height":100.0}},
                          {"kind":"background","args":{"color":-2130771968}}]},
            {"type":"Text","id":"root/3/1","props":{"text":"overlay"}}
          ]},
          {"type":"Toggle","id":"root/4","props":{"isOn":true,"onChange":2},
           "children":[{"type":"Text","id":"root/4/label/0","props":{"text":"Enabled"}}]}
        ]}
    """.trimIndent()

    val unknown = """
        {"type":"Mystery","id":"root"}
    """.trimIndent()

    val all = mapOf(
        "Counter" to counter,
        "Stacks" to stacks,
        "Unknown" to unknown,
    )
}

fun main() = application {
    Window(onCloseRequest = ::exitApplication, title = "AndroidSwiftUI desktop rig") {
        MaterialTheme {
            Surface {
                RigContent()
            }
        }
    }
}

@Composable
private fun RigContent() {
    val store = remember { TreeStore() }
    var selected by remember { mutableStateOf("Stacks") }
    Column(modifier = Modifier.padding(16.dp)) {
        Row {
            for ((name, json) in Fixtures.all) {
                TextButton(onClick = {
                    selected = name
                    store.updateJson(json)
                }) {
                    androidx.compose.material3.Text(if (name == selected) "[$name]" else name)
                }
            }
        }
        HorizontalDivider()
        val root = store.root
        if (root == null) {
            store.updateJson(Fixtures.all.getValue(selected))
        } else {
            Render(root)
        }
    }
}
