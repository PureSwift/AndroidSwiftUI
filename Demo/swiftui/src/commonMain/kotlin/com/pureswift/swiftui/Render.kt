package com.pureswift.swiftui

import androidx.compose.foundation.background
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.shape.RoundedCornerShape

/// Interprets a Swift-evaluated node tree into Material 3 composables.
///
/// One `when` per node type; unknown types render a diagnostic so schema
/// drift is visible rather than silent.
@Composable
fun Render(node: ViewNode) {
    key(node.id) {
        when (node.type) {
            "Text" -> Text(
                text = node.string("text") ?: "",
                modifier = node.composeModifiers(),
            )

            "Button" -> {
                val onTap = node.long("onTap")
                Button(
                    onClick = { onTap?.let { SwiftBridge.sink.invokeVoid(it) } },
                    modifier = node.composeModifiers(),
                ) {
                    RenderChildren(node)
                }
            }

            "Toggle" -> {
                val onChange = node.long("onChange")
                Row(verticalAlignment = Alignment.CenterVertically, modifier = node.composeModifiers()) {
                    RenderChildren(node)
                    Switch(
                        checked = node.bool("isOn") ?: false,
                        onCheckedChange = { onChange?.let { id -> SwiftBridge.sink.invokeBool(id, it) } },
                    )
                }
            }

            "VStack" -> Column(
                verticalArrangement = node.double("spacing")
                    ?.let { Arrangement.spacedBy(it.dp) } ?: Arrangement.Top,
                horizontalAlignment = when (node.string("alignment")) {
                    "leading" -> Alignment.Start
                    "trailing" -> Alignment.End
                    else -> Alignment.CenterHorizontally
                },
                modifier = node.composeModifiers(),
            ) {
                RenderColumnChildren(node)
            }

            "HStack" -> Row(
                horizontalArrangement = node.double("spacing")
                    ?.let { Arrangement.spacedBy(it.dp) } ?: Arrangement.Start,
                verticalAlignment = when (node.string("alignment")) {
                    "top" -> Alignment.Top
                    "bottom" -> Alignment.Bottom
                    else -> Alignment.CenterVertically
                },
                modifier = node.composeModifiers(),
            ) {
                RenderRowChildren(node)
            }

            "ZStack" -> Box(
                contentAlignment = zStackAlignment(node),
                modifier = node.composeModifiers(),
            ) {
                RenderChildren(node)
            }

            // Outside a stack, a Spacer has no axis to expand along; render as empty.
            "Spacer" -> Spacer(modifier = node.composeModifiers())

            "Divider" -> HorizontalDivider(modifier = node.composeModifiers())

            "ScrollView" -> {
                val state = rememberScrollState()
                if (node.string("axis") == "horizontal") {
                    Row(modifier = node.composeModifiers().horizontalScroll(state)) { RenderChildren(node) }
                } else {
                    Column(modifier = node.composeModifiers().verticalScroll(state)) { RenderChildren(node) }
                }
            }

            "Color" -> Box(
                modifier = node.composeModifiers()
                    .background(Color((node.long("color") ?: 0).toInt()))
            )

            "Image" -> Text("[${node.string("name") ?: "image"}]", modifier = node.composeModifiers())

            "ProgressView" -> {
                val value = node.double("value")
                if (value != null) {
                    LinearProgressIndicator(progress = { value.toFloat() }, modifier = node.composeModifiers().fillMaxWidth())
                } else {
                    CircularProgressIndicator(modifier = node.composeModifiers())
                }
            }

            "Slider" -> {
                val onChange = node.long("onChange")
                val min = (node.double("min") ?: 0.0).toFloat()
                val max = (node.double("max") ?: 1.0).toFloat()
                Slider(
                    value = (node.double("value") ?: 0.0).toFloat(),
                    onValueChange = { onChange?.let { id -> SwiftBridge.sink.invokeDouble(id, it.toDouble()) } },
                    valueRange = min..max,
                    modifier = node.composeModifiers().fillMaxWidth(),
                )
            }

            "TextField" -> RenderTextField(node)

            "Picker" -> RenderPicker(node)

            "EmptyView" -> Unit

            "Composable" -> ComposableRegistry.Render(node)

            else -> Text(
                text = "⟨unknown node: ${node.type}⟩",
                color = Color.Red,
                modifier = node.composeModifiers(),
            )
        }
    }
}

@Composable
private fun RenderChildren(node: ViewNode) {
    for (child in node.children) {
        Render(child)
    }
}

// Uncontrolled-with-reconciliation: Compose owns the field's TextFieldValue
// (cursor/selection); `lastSent` tracks the value we last pushed to Swift, so
// an echo (Swift's tree carrying our own text back) leaves the cursor alone,
// while an external change adopts Swift's value with the cursor at the end.
@Composable
private fun RenderTextField(node: ViewNode) {
    val onChange = node.long("onChange")
    val swiftText = node.string("text") ?: ""
    var local by remember(node.id) { mutableStateOf(TextFieldValue(swiftText)) }
    var lastSent by remember(node.id) { mutableStateOf(swiftText) }
    if (swiftText != lastSent) {
        local = TextFieldValue(swiftText, selection = androidx.compose.ui.text.TextRange(swiftText.length))
        lastSent = swiftText
    }
    OutlinedTextField(
        value = local,
        onValueChange = { v ->
            local = v
            if (v.text != lastSent) {
                lastSent = v.text
                onChange?.let { SwiftBridge.sink.invokeString(it, v.text) }
            }
        },
        label = { Text(node.string("placeholder") ?: "") },
        modifier = node.composeModifiers().fillMaxWidth(),
    )
}

@Composable
private fun RenderPicker(node: ViewNode) {
    val onChange = node.long("onChange")
    val selection = node.string("selection")
    var expanded by remember { mutableStateOf(false) }
    // options come from the tagged children: (tag value, display text)
    val options = node.children.mapNotNull { child ->
        val tag = child.modifiers.firstOrNull { it.kind == "tag" }?.args?.let { (it["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content }
        val text = pickerLabel(child)
        if (tag != null) tag to text else null
    }
    val currentLabel = options.firstOrNull { it.first == selection }?.second ?: (selection ?: "")
    Row(modifier = node.composeModifiers().fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(node.string("title") ?: "")
        Spacer(modifier = Modifier.weight(1f))
        TextButton(onClick = { expanded = true }) { Text(currentLabel) }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            for ((value, label) in options) {
                DropdownMenuItem(text = { Text(label) }, onClick = {
                    expanded = false
                    onChange?.let { SwiftBridge.sink.invokeString(it, value) }
                })
            }
        }
    }
}

// A picker row's display text: the first Text descendant.
private fun pickerLabel(node: ViewNode): String {
    if (node.type == "Text") return node.string("text") ?: ""
    for (child in node.children) {
        val label = pickerLabel(child)
        if (label.isNotEmpty()) return label
    }
    return ""
}

// `Modifier.weight` only exists inside RowScope/ColumnScope, so stacks render
// their children through scope-aware loops that give Spacer its expansion.

@Composable
private fun ColumnScope.RenderColumnChildren(node: ViewNode) {
    for (child in node.children) {
        if (child.type == "Spacer") {
            Spacer(modifier = Modifier.weight(1f))
        } else {
            Render(child)
        }
    }
}

@Composable
private fun RowScope.RenderRowChildren(node: ViewNode) {
    for (child in node.children) {
        if (child.type == "Spacer") {
            Spacer(modifier = Modifier.weight(1f))
        } else {
            Render(child)
        }
    }
}

private fun zStackAlignment(node: ViewNode): Alignment {
    val horizontal = node.string("horizontal") ?: "center"
    val vertical = node.string("vertical") ?: "center"
    return when (vertical to horizontal) {
        "top" to "leading" -> Alignment.TopStart
        "top" to "center" -> Alignment.TopCenter
        "top" to "trailing" -> Alignment.TopEnd
        "center" to "leading" -> Alignment.CenterStart
        "center" to "trailing" -> Alignment.CenterEnd
        "bottom" to "leading" -> Alignment.BottomStart
        "bottom" to "center" -> Alignment.BottomCenter
        "bottom" to "trailing" -> Alignment.BottomEnd
        else -> Alignment.Center
    }
}

/// Folds a node's ordered modifier chain into a Compose `Modifier`.
/// The chain arrives outermost-first, which is exactly Compose's order.
internal fun ViewNode.composeModifiers(): Modifier {
    var modifier: Modifier = Modifier
    for (entry in modifiers) {
        modifier = when (entry.kind) {
            "padding" -> {
                val top = entry.args.double("top")
                if (top != null) {
                    modifier.padding(
                        top = top.dp,
                        start = (entry.args.double("leading") ?: 0.0).dp,
                        bottom = (entry.args.double("bottom") ?: 0.0).dp,
                        end = (entry.args.double("trailing") ?: 0.0).dp,
                    )
                } else {
                    modifier.padding(16.dp) // system default
                }
            }

            "frame" -> {
                val width = entry.args.double("width")
                val height = entry.args.double("height")
                when {
                    width != null && height != null -> modifier.size(width.dp, height.dp)
                    width != null -> modifier.width(width.dp)
                    height != null -> modifier.height(height.dp)
                    else -> modifier
                }
            }

            "background" -> {
                val argb = entry.args.long("color") ?: 0
                modifier.background(Color(argb.toInt()))
            }

            "cornerRadius" -> {
                val radius = entry.args.double("radius") ?: 0.0
                modifier.clip(RoundedCornerShape(radius.dp))
            }

            "offset" -> {
                val x = entry.args.double("x") ?: 0.0
                val y = entry.args.double("y") ?: 0.0
                modifier.offset { IntOffset((x.dp.value).toInt(), (y.dp.value).toInt()) }
            }

            "rotation" -> modifier.rotate((entry.args.double("degrees") ?: 0.0).toFloat())

            "scale" -> modifier.scale((entry.args.double("scale") ?: 1.0).toFloat())

            "opacity" -> modifier.alpha((entry.args.double("opacity") ?: 1.0).toFloat())

            else -> modifier // unknown modifier: ignore, never crash rendering
        }
    }
    return modifier
}
