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
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.togetherWith
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.layout.Column as LayoutColumn
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyHorizontalGrid
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateMapOf
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

            "NavStack" -> RenderNavStack(node)

            "NavigationLink" -> TextButton(
                onClick = { node.long("onTap")?.let { SwiftBridge.sink.invokeVoid(it) } },
                modifier = node.composeModifiers(),
            ) { RenderChildren(node) }

            "TabView" -> RenderTabView(node)

            "List" -> RenderList(node)

            "LazyVGrid" -> RenderGrid(node, vertical = true)

            "LazyHGrid" -> RenderGrid(node, vertical = false)

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

// Sheets and alerts ride as hidden children; the presentation layer shows
// them, so the normal child loop skips them.
private fun ViewNode.isPresentation(): Boolean = type == "Sheet" || type == "Alert"

@Composable
private fun RenderChildren(node: ViewNode) {
    for (child in node.children) {
        if (child.isPresentation()) continue
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
        if (child.isPresentation()) continue
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
        if (child.isPresentation()) continue
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


@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RenderNavStack(node: ViewNode) {
    val titles = node.stringArray("titles")
    val onPop = node.long("onPop")
    val depth = node.children.size
    // cache rendered screens by index so a popped screen can animate out
    val topIndex = depth - 1
    Scaffold(
        topBar = {
            val title = titles.getOrNull(topIndex).orEmpty()
            if (title.isNotEmpty() || depth > 1) {
                TopAppBar(
                    title = { Text(title) },
                    navigationIcon = {
                        if (depth > 1) {
                            IconButton(onClick = { onPop?.let { SwiftBridge.sink.invokeVoid(it) } }) {
                                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                            }
                        }
                    },
                )
            }
        },
    ) { padding ->
        AnimatedContent(
            targetState = topIndex,
            transitionSpec = {
                if (targetState > initialState) {
                    (slideInHorizontally { it }) togetherWith (slideOutHorizontally { -it / 3 })
                } else {
                    (slideInHorizontally { -it / 3 }) togetherWith (slideOutHorizontally { it })
                }
            },
            modifier = Modifier.fillMaxSize(),
            label = "nav",
        ) { index ->
            LayoutColumn(modifier = Modifier.padding(padding)) {
                node.children.getOrNull(index)?.let { Render(it) }
            }
        }
    }
    RenderSheetsAndAlerts(node.children.getOrNull(topIndex))
}

@Composable
private fun RenderTabView(node: ViewNode) {
    val selection = node.long("selection")?.toInt() ?: 0
    val onSelect = node.long("onSelect")
    Scaffold(
        bottomBar = {
            NavigationBar {
                node.children.forEachIndexed { index, tab ->
                    val label = tab.modifiers.firstOrNull { it.kind == "tabItem" }
                        ?.args?.let { (it["text"] as? kotlinx.serialization.json.JsonPrimitive)?.content } ?: ""
                    val tag = tab.modifiers.firstOrNull { it.kind == "tag" }
                        ?.args?.let { (it["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content?.toIntOrNull() } ?: index
                    NavigationBarItem(
                        selected = tag == selection,
                        onClick = { onSelect?.let { SwiftBridge.sink.invokeInt(it, tag) } },
                        icon = {},
                        label = { Text(label) },
                    )
                }
            }
        },
    ) { padding ->
        val current = node.children.firstOrNull { tab ->
            val tag = tab.modifiers.firstOrNull { it.kind == "tag" }
                ?.args?.let { (it["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content?.toIntOrNull() }
            tag == selection
        } ?: node.children.getOrNull(selection)
        LayoutColumn(modifier = Modifier.padding(padding)) {
            current?.let { Render(it) }
        }
    }
}

// Sheets and alerts ride as hidden children of a screen node; present them
// when the screen carries the corresponding flag.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RenderSheetsAndAlerts(screen: ViewNode?) {
    if (screen == null) return
    for (child in screen.children) {
        when (child.type) {
            "Sheet" -> {
                val onDismiss = child.long("onDismiss")
                ModalBottomSheet(onDismissRequest = { onDismiss?.let { SwiftBridge.sink.invokeVoid(it) } }) {
                    child.children.firstOrNull()?.let { Render(it) }
                }
            }
            "Alert" -> RenderAlert(child)
        }
    }
}

@Composable
private fun RenderAlert(node: ViewNode) {
    val onDismiss = node.long("onDismiss")
    val buttons = (node.props["buttons"] as? kotlinx.serialization.json.JsonArray) ?: kotlinx.serialization.json.JsonArray(emptyList())
    val parsed = buttons.mapNotNull { entry ->
        val arr = entry as? kotlinx.serialization.json.JsonArray ?: return@mapNotNull null
        val title = (arr[0] as? kotlinx.serialization.json.JsonPrimitive)?.content ?: return@mapNotNull null
        val id = (arr[2] as? kotlinx.serialization.json.JsonPrimitive)?.content?.toLongOrNull() ?: return@mapNotNull null
        title to id
    }
    AlertDialog(
        onDismissRequest = { onDismiss?.let { SwiftBridge.sink.invokeVoid(it) } },
        title = { Text(node.string("title") ?: "") },
        text = { node.string("message")?.let { Text(it) } },
        confirmButton = {
            parsed.firstOrNull()?.let { (title, id) ->
                TextButton(onClick = { SwiftBridge.sink.invokeVoid(id) }) { Text(title) }
            }
        },
        dismissButton = {
            if (parsed.size > 1) {
                val (title, id) = parsed[1]
                TextButton(onClick = { SwiftBridge.sink.invokeVoid(id) }) { Text(title) }
            }
        },
    )
}

private fun ViewNode.stringArray(key: String): List<String> {
    val arr = props[key] as? kotlinx.serialization.json.JsonArray ?: return emptyList()
    return arr.mapNotNull { (it as? kotlinx.serialization.json.JsonPrimitive)?.content }
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RenderList(node: ViewNode) {
    val provider = node.long("itemProvider") ?: return
    val count = node.count ?: 0
    val keys = node.stringArray("keys")
    val onRefresh = node.long("onRefresh")
    val list: @Composable () -> Unit = {
        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(count = count, key = { keys.getOrNull(it) ?: it }) { index ->
                // one JNI call per newly-visible row; re-fetched when the tree
                // (hence the provider id) changes
                val row = remember(provider, index) { SwiftBridge.sink.itemNode(provider, index) }
                row?.let { Render(it) }
            }
        }
    }
    if (onRefresh != null) {
        var refreshing by remember { mutableStateOf(false) }
        PullToRefreshBox(
            isRefreshing = refreshing,
            onRefresh = {
                refreshing = true
                SwiftBridge.sink.invokeVoid(onRefresh)
            },
        ) { list() }
        // clear the indicator once the tree updates (new content arrived)
        LaunchedEffect(node.count) { refreshing = false }
    } else {
        list()
    }
}

@Composable
private fun RenderGrid(node: ViewNode, vertical: Boolean) {
    val spacing = (node.double("spacing") ?: 8.0).dp
    val cells = node.double("adaptiveMin")?.let { GridCells.Adaptive(it.dp) }
        ?: GridCells.Fixed(node.long("trackCount")?.toInt() ?: 1)
    if (vertical) {
        LazyVerticalGrid(
            columns = cells,
            verticalArrangement = Arrangement.spacedBy(spacing),
            horizontalArrangement = Arrangement.spacedBy(spacing),
            modifier = node.composeModifiers(),
        ) {
            items(node.children.size) { Render(node.children[it]) }
        }
    } else {
        LazyHorizontalGrid(
            rows = cells,
            verticalArrangement = Arrangement.spacedBy(spacing),
            horizontalArrangement = Arrangement.spacedBy(spacing),
            modifier = node.composeModifiers(),
        ) {
            items(node.children.size) { Render(node.children[it]) }
        }
    }
}
