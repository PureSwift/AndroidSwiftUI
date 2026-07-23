package com.pureswift.swiftui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
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
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
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
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Face
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.compositionLocalOf
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.shape.RoundedCornerShape

/// The easing description a `withAnimation` tree carries on its root — while
/// it is in scope, modifier folding eases changed numeric values instead of
/// snapping them.
internal data class AnimSpec(val curve: String, val durationMs: Int)

internal val LocalAnimationSpec = compositionLocalOf<AnimSpec?> { null }

/// Interprets a Swift-evaluated node tree into Material 3 composables.
///
/// One `when` per node type; unknown types render a diagnostic so schema
/// drift is visible rather than silent.
///
/// The animation provider is unconditional (inheriting when the node carries
/// no spec of its own — only the root ever does) so that an animated tree
/// arriving does not change the composition's structure: a branch switch here
/// would tear down every remembered Animatable and snap instead of easing.
@Composable
fun Render(node: ViewNode) {
    val spec = node.string("animationCurve")?.let {
        AnimSpec(it, (node.double("animationDurationMs") ?: 350.0).toInt())
    } ?: LocalAnimationSpec.current
    CompositionLocalProvider(LocalAnimationSpec provides spec) { RenderResolved(node) }
}

@Composable
private fun RenderResolved(node: ViewNode) {
    key(node.id) {
        RenderEffects(node)
        when (node.type) {
            "Text" -> RenderText(node)

            "Button" -> {
                val onTap = node.long("onTap")
                Button(
                    onClick = { onTap?.let { SwiftBridge.sink.invokeVoid(it) } },
                    enabled = !node.isDisabled(),
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

            // A Color greedily fills the space offered it (SwiftUI semantics);
            // fillMaxWidth is applied after the chain so an explicit frame width
            // still constrains it.
            "Color" -> Box(
                modifier = node.composeModifiers()
                    .fillMaxWidth()
                    .background(Color((node.long("color") ?: 0).toInt()))
            )

            "Image" -> RenderImage(node)

            "Overlay" -> Box(
                contentAlignment = zStackAlignment(node),
                modifier = node.composeModifiers(),
            ) {
                node.children.getOrNull(0)?.let { Render(it) }
                Box(modifier = Modifier.matchParentSize(), contentAlignment = zStackAlignment(node)) {
                    node.children.getOrNull(1)?.let { Render(it) }
                }
            }

            "Shape" -> RenderShape(node)

            "LinearGradient" -> RenderGradient(node)

            "Map" -> RenderMap(node)

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

            "Stepper" -> RenderStepper(node)

            "Menu" -> RenderMenu(node)

            "DatePicker" -> RenderDatePicker(node)

            "Picker" -> RenderPicker(node)

            "NavStack" -> RenderNavStack(node)

            "NavigationLink" -> TextButton(
                onClick = { node.long("onTap")?.let { SwiftBridge.sink.invokeVoid(it) } },
                modifier = node.composeModifiers(),
            ) { RenderChildren(node) }

            "TabView" -> RenderTabView(node)

            "Form" -> RenderForm(node)

            "Section" -> RenderSection(node)

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
        visualTransformation = if (node.bool("secure") == true) PasswordVisualTransformation() else VisualTransformation.None,
        modifier = node.composeModifiers().fillMaxWidth(),
    )
}

// Label, then − / + edge buttons pushed to the trailing side.
@Composable
private fun RenderStepper(node: ViewNode) {
    val onIncrement = node.long("onIncrement")
    val onDecrement = node.long("onDecrement")
    Row(verticalAlignment = Alignment.CenterVertically, modifier = node.composeModifiers().fillMaxWidth()) {
        RenderChildren(node)
        Spacer(modifier = Modifier.weight(1f))
        TextButton(onClick = { onDecrement?.let { SwiftBridge.sink.invokeVoid(it) } }) { Text("−", fontSize = 20.sp) }
        TextButton(onClick = { onIncrement?.let { SwiftBridge.sink.invokeVoid(it) } }) { Text("+", fontSize = 20.sp) }
    }
}

// A Form scrolls its Sections; non-Section children still render, ungrouped.
@Composable
private fun RenderForm(node: ViewNode) {
    val state = rememberScrollState()
    Column(modifier = node.composeModifiers().fillMaxSize().verticalScroll(state).padding(vertical = 8.dp)) {
        RenderChildren(node)
    }
}

// An inset, rounded group: uppercase header, rows separated by dividers, footer.
@Composable
private fun RenderSection(node: ViewNode) {
    Column(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp)) {
        node.string("header")?.let {
            Text(
                it.uppercase(),
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 4.dp, bottom = 6.dp),
            )
        }
        Surface(
            color = MaterialTheme.colorScheme.surfaceVariant,
            shape = RoundedCornerShape(10.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Column {
                val rows = node.children.filter { !it.isPresentation() }
                rows.forEachIndexed { index, row ->
                    if (index > 0) HorizontalDivider()
                    Box(modifier = Modifier.padding(horizontal = 12.dp, vertical = 10.dp)) { Render(row) }
                }
            }
        }
        node.string("footer")?.let {
            Text(
                it,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 4.dp, top = 6.dp),
            )
        }
    }
}

// A label row with a trailing formatted-date button; tapping opens a Material3
// date picker dialog. Selection round-trips as UTC epoch millis, matching both
// Date's representation and DatePickerState's currency, so no conversion.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RenderDatePicker(node: ViewNode) {
    val onChange = node.long("onChange")
    val millis = (node.double("millis") ?: 0.0).toLong()
    var showDialog by remember { mutableStateOf(false) }
    Row(verticalAlignment = Alignment.CenterVertically, modifier = node.composeModifiers().fillMaxWidth()) {
        RenderChildren(node)
        Spacer(modifier = Modifier.weight(1f))
        TextButton(onClick = { showDialog = true }) { Text(formatDateMillis(millis)) }
    }
    if (showDialog) {
        val state = rememberDatePickerState(initialSelectedDateMillis = millis)
        DatePickerDialog(
            onDismissRequest = { showDialog = false },
            confirmButton = {
                TextButton(onClick = {
                    showDialog = false
                    state.selectedDateMillis?.let { picked -> onChange?.let { SwiftBridge.sink.invokeDouble(it, picked.toDouble()) } }
                }) { Text("OK") }
            },
            dismissButton = { TextButton(onClick = { showDialog = false }) { Text("Cancel") } },
        ) {
            DatePicker(state = state)
        }
    }
}

private val monthAbbreviations = arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

private fun formatDateMillis(millis: Long): String {
    val calendar = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
    calendar.timeInMillis = millis
    val month = monthAbbreviations[calendar.get(java.util.Calendar.MONTH)]
    val day = calendar.get(java.util.Calendar.DAY_OF_MONTH)
    val year = calendar.get(java.util.Calendar.YEAR)
    return "$month $day, $year"
}

// A trigger button opening a dropdown; each child Button becomes a menu item
// firing its own tap callback.
@Composable
private fun RenderMenu(node: ViewNode) {
    var expanded by remember { mutableStateOf(false) }
    Box {
        TextButton(onClick = { expanded = true }) { Text(node.string("label") ?: "") }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            for (child in node.children) {
                if (child.isPresentation()) continue
                val onTap = child.long("onTap")
                DropdownMenuItem(
                    text = { Text(pickerLabel(child)) },
                    onClick = {
                        expanded = false
                        onTap?.let { SwiftBridge.sink.invokeVoid(it) }
                    },
                )
            }
        }
    }
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

// Lifecycle modifiers (onAppear/onDisappear/task/onChange) install Compose
// effects rather than folding into the Modifier chain. Keyed within the node's
// `key(id)` scope, so onAppear fires once on entry and onDisappear on exit,
// surviving recomposition.
@Composable
private fun RenderEffects(node: ViewNode) {
    val onAppear = node.modifiers.firstOrNull { it.kind == "onAppear" }?.args?.long("action")
    val onDisappear = node.modifiers.firstOrNull { it.kind == "onDisappear" }?.args?.long("action")
    val task = node.modifiers.firstOrNull { it.kind == "task" }?.args?.long("action")
    val onChange = node.modifiers.firstOrNull { it.kind == "onChange" }

    if (onAppear != null || onDisappear != null) {
        DisposableEffect(Unit) {
            onAppear?.let { SwiftBridge.sink.invokeVoid(it) }
            onDispose { onDisappear?.let { SwiftBridge.sink.invokeVoid(it) } }
        }
    }
    if (task != null) {
        LaunchedEffect(Unit) { SwiftBridge.sink.invokeVoid(task) }
    }
    if (onChange != null) {
        val token = onChange.args.string("token")
        val action = onChange.args.long("action")
        // skip the initial composition; fire when the token changes thereafter
        var primed by remember(node.id) { mutableStateOf(false) }
        LaunchedEffect(token) {
            if (primed) action?.let { SwiftBridge.sink.invokeVoid(it) } else primed = true
        }
    }
}

private fun ViewNode.isDisabled(): Boolean =
    modifiers.any { it.kind == "disabled" && (it.args["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content == "true" }

// A shape fills its (frame-derived) size with its fill color; without a frame
// it collapses to zero, matching this backend's no-layout-engine limitation.
@Composable
private fun RenderShape(node: ViewNode) {
    val fill = node.long("fill")?.let { Color(it.toInt()) } ?: Color(0xFF000000)
    val shape = when (node.string("shape")) {
        "circle" -> CircleShape
        "capsule" -> RoundedCornerShape(percent = 50)
        "roundedRectangle" -> RoundedCornerShape((node.double("cornerRadius") ?: 0.0).dp)
        else -> RectangleShape
    }
    Box(modifier = node.composeModifiers().background(fill, shape))
}

// A schematic map: the visible region maps linearly onto the box, markers sit
// at their proportional position, and the center coordinate is captioned.
// Real tiles come from a registered composable (maps SDKs need an API key).
@Composable
private fun RenderMap(node: ViewNode) {
    val centerLat = node.double("centerLatitude") ?: 0.0
    val centerLon = node.double("centerLongitude") ?: 0.0
    val spanLat = (node.double("spanLatitude") ?: 1.0).coerceAtLeast(1e-6)
    val spanLon = (node.double("spanLongitude") ?: 1.0).coerceAtLeast(1e-6)
    Box(
        modifier = node.composeModifiers()
            .fillMaxWidth()
            .height(220.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(Color(0xFFDCE8DC.toInt()))
            .border(1.dp, Color(0xFFB8CCB8.toInt()), RoundedCornerShape(8.dp)),
    ) {
        for (marker in node.children) {
            if (marker.type != "MapMarker") continue
            val lat = marker.double("latitude") ?: continue
            val lon = marker.double("longitude") ?: continue
            // normalized region position → alignment bias (north at the top)
            val fx = ((lon - (centerLon - spanLon / 2)) / spanLon).coerceIn(0.0, 1.0)
            val fy = (((centerLat + spanLat / 2) - lat) / spanLat).coerceIn(0.0, 1.0)
            val tint = marker.long("tint")?.let { Color(it.toInt()) } ?: Color(0xFFD32F2F.toInt())
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.align(
                    androidx.compose.ui.BiasAlignment((2 * fx - 1).toFloat(), (2 * fy - 1).toFloat())
                ),
            ) {
                Box(modifier = Modifier.size(12.dp).clip(CircleShape).background(tint))
                Text(marker.string("title") ?: "", fontSize = 11.sp)
            }
        }
        Text(
            "${formatCoordinate(centerLat)}, ${formatCoordinate(centerLon)}",
            fontSize = 11.sp,
            color = Color(0xFF667066.toInt()),
            modifier = Modifier.align(Alignment.BottomCenter).padding(4.dp),
        )
    }
}

private fun formatCoordinate(value: Double): String {
    val thousandths = kotlin.math.round(value * 1000) / 1000
    return thousandths.toString()
}

// Horizontal/vertical when the endpoints share an axis, else a diagonal linear
// gradient across the frame.
@Composable
private fun RenderGradient(node: ViewNode) {
    val colors = node.colorList("colors").ifEmpty { listOf(Color.Transparent, Color.Transparent) }
    val startX = node.double("startX") ?: 0.0
    val startY = node.double("startY") ?: 0.5
    val endX = node.double("endX") ?: 1.0
    val endY = node.double("endY") ?: 0.5
    val brush = when {
        startY == endY -> Brush.horizontalGradient(colors)
        startX == endX -> Brush.verticalGradient(colors)
        else -> Brush.linearGradient(colors)
    }
    // A gradient fills the available width by default (SwiftUI semantics);
    // fillMaxWidth is applied after the chain so an explicit frame width still
    // constrains it.
    Box(modifier = node.composeModifiers().fillMaxWidth().background(brush))
}

@Composable
private fun RenderImage(node: ViewNode) {
    val icon = node.string("systemName")?.let { materialIcon(it) }
    if (icon != null) {
        val tint = node.modifiers.firstOrNull { it.kind == "foregroundColor" }
            ?.args?.long("color")?.let { Color(it.toInt()) }
        Icon(
            imageVector = icon,
            contentDescription = node.string("systemName"),
            tint = tint ?: LocalContentColor.current,
            modifier = node.composeModifiers(),
        )
    } else {
        Text("[${node.string("name") ?: "image"}]", modifier = node.composeModifiers())
    }
}

private fun ViewNode.colorList(key: String): List<Color> {
    val arr = props[key] as? kotlinx.serialization.json.JsonArray ?: return emptyList()
    return arr.mapNotNull { (it as? kotlinx.serialization.json.JsonPrimitive)?.content?.toLongOrNull()?.let { c -> Color(c.toInt()) } }
}

// A curated SF Symbol → Material icon map; unknown names fall back to the
// placeholder text so gaps stay visible.
private fun materialIcon(name: String): ImageVector? = when (name) {
    "star", "star.fill" -> Icons.Filled.Star
    "heart", "heart.fill" -> Icons.Filled.Favorite
    "trash", "trash.fill" -> Icons.Filled.Delete
    "person", "person.fill" -> Icons.Filled.Person
    "gear", "gearshape", "gearshape.fill" -> Icons.Filled.Settings
    "house", "house.fill" -> Icons.Filled.Home
    "magnifyingglass" -> Icons.Filled.Search
    "plus" -> Icons.Filled.Add
    "checkmark" -> Icons.Filled.Check
    "xmark" -> Icons.Filled.Close
    "bell", "bell.fill" -> Icons.Filled.Notifications
    "envelope", "envelope.fill" -> Icons.Filled.Email
    "phone", "phone.fill" -> Icons.Filled.Phone
    "lock", "lock.fill" -> Icons.Filled.Lock
    "cart", "cart.fill" -> Icons.Filled.ShoppingCart
    "hand.thumbsup", "hand.thumbsup.fill" -> Icons.Filled.ThumbUp
    "info", "info.circle" -> Icons.Filled.Info
    "exclamationmark.triangle" -> Icons.Filled.Warning
    "square.and.arrow.up" -> Icons.Filled.Share
    "line.3.horizontal" -> Icons.Filled.Menu
    "ellipsis" -> Icons.Filled.MoreVert
    "play", "play.fill" -> Icons.Filled.PlayArrow
    "arrow.clockwise" -> Icons.Filled.Refresh
    "calendar" -> Icons.Filled.DateRange
    "face.smiling" -> Icons.Filled.Face
    "location", "location.fill" -> Icons.Filled.LocationOn
    else -> null
}

// Text-styling modifiers describe attributes of the Text composable itself,
// not the layout Modifier chain, so they are read off the node here and passed
// as `Text(...)` parameters. Later (innermost) entries win for scalar
// attributes. Layout modifiers in the same chain still apply via composeModifiers().
@Composable
private fun RenderText(node: ViewNode) {
    var color = Color.Unspecified
    var fontSize: TextUnit = TextUnit.Unspecified
    var weight: FontWeight? = null
    var fontStyle: FontStyle? = null
    var maxLines = Int.MAX_VALUE
    var textAlign: TextAlign? = null
    for (m in node.modifiers) {
        when (m.kind) {
            "font" -> {
                m.args.string("style")?.let { style ->
                    fontSize = fontSizeForStyle(style).sp
                    if (weight == null) weight = defaultWeightForStyle(style)
                }
                m.args.double("size")?.let { fontSize = it.sp }
                m.args.string("weight")?.let { weight = fontWeightFor(it) }
            }
            "fontWeight" -> m.args.string("weight")?.let { weight = fontWeightFor(it) }
            "italic" -> fontStyle = FontStyle.Italic
            "foregroundColor" -> m.args.long("color")?.let { color = Color(it.toInt()) }
            "lineLimit" -> maxLines = m.args.long("count")?.toInt() ?: Int.MAX_VALUE
            "multilineTextAlignment" -> textAlign = when (m.args.string("value")) {
                "leading" -> TextAlign.Start
                "trailing" -> TextAlign.End
                else -> TextAlign.Center
            }
        }
    }
    Text(
        text = node.string("text") ?: "",
        color = color,
        fontSize = fontSize,
        fontWeight = weight,
        fontStyle = fontStyle,
        maxLines = maxLines,
        textAlign = textAlign,
        modifier = node.composeModifiers(),
    )
}

// SwiftUI named text styles → point sizes (Compose has no built-in analog).
private fun fontSizeForStyle(style: String): Double = when (style) {
    "largeTitle" -> 34.0
    "title" -> 28.0
    "title2" -> 22.0
    "title3" -> 20.0
    "headline" -> 17.0
    "body" -> 17.0
    "callout" -> 16.0
    "subheadline" -> 15.0
    "footnote" -> 13.0
    "caption" -> 12.0
    "caption2" -> 11.0
    else -> 17.0
}

// Only headline carries a non-regular default weight in SwiftUI.
private fun defaultWeightForStyle(style: String): FontWeight? =
    if (style == "headline") FontWeight.SemiBold else null

private fun fontWeightFor(name: String): FontWeight = when (name) {
    "ultraLight" -> FontWeight.ExtraLight
    "thin" -> FontWeight.Thin
    "light" -> FontWeight.Light
    "regular" -> FontWeight.Normal
    "medium" -> FontWeight.Medium
    "semibold" -> FontWeight.SemiBold
    "bold" -> FontWeight.Bold
    "heavy" -> FontWeight.ExtraBold
    "black" -> FontWeight.Black
    else -> FontWeight.Normal
}

/// Folds a node's ordered modifier chain into a Compose `Modifier`.
/// The chain arrives outermost-first, which is exactly Compose's order.
///
/// Numeric values fold through `animate*AsState` unconditionally so their
/// internal state persists across trees; the spec is a tween/spring while an
/// animation (explicit `withAnimation` tree, or this node's `.animation`
/// modifier) applies, and `snap` otherwise.
@Composable
internal fun ViewNode.composeModifiers(): Modifier {
    val implicit = modifiers.firstOrNull { it.kind == "animation" && it.args["curve"] != null }
        ?.let { AnimSpec(it.args.string("curve") ?: "easeInOut", (it.args.double("durationMs") ?: 350.0).toInt()) }
    val spec = implicit ?: LocalAnimationSpec.current
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
                    width != null && height != null -> modifier.size(animatedDp(width.dp, spec), animatedDp(height.dp, spec))
                    width != null -> modifier.width(animatedDp(width.dp, spec))
                    height != null -> modifier.height(animatedDp(height.dp, spec))
                    else -> modifier
                }
            }

            "background" -> {
                val argb = entry.args.long("color") ?: 0
                modifier.background(animatedColor(Color(argb.toInt()), spec))
            }

            "cornerRadius" -> {
                val radius = entry.args.double("radius") ?: 0.0
                modifier.clip(RoundedCornerShape(animatedDp(radius.dp, spec)))
            }

            "offset" -> {
                val x = entry.args.double("x") ?: 0.0
                val y = entry.args.double("y") ?: 0.0
                modifier.offset(x = animatedDp(x.dp, spec), y = animatedDp(y.dp, spec))
            }

            "rotation" -> modifier.rotate(animatedFloat((entry.args.double("degrees") ?: 0.0).toFloat(), spec))

            "scale" -> modifier.scale(animatedFloat((entry.args.double("scale") ?: 1.0).toFloat(), spec))

            "opacity" -> modifier.alpha(animatedFloat((entry.args.double("opacity") ?: 1.0).toFloat(), spec))

            "border" -> {
                val color = entry.args.long("color")?.let { Color(it.toInt()) } ?: Color.Black
                modifier.border((entry.args.double("width") ?: 1.0).dp, color)
            }

            "shadow" -> modifier.shadow((entry.args.double("radius") ?: 0.0).dp)

            "clipShape" -> {
                val shape = when (entry.args.string("shape")) {
                    "circle" -> CircleShape
                    "capsule" -> RoundedCornerShape(percent = 50)
                    "roundedRectangle" -> RoundedCornerShape((entry.args.double("cornerRadius") ?: 0.0).dp)
                    else -> RectangleShape
                }
                modifier.clip(shape)
            }

            "onTapGesture" -> {
                val id = entry.args.long("action")
                if (id != null) modifier.clickable { SwiftBridge.sink.invokeVoid(id) } else modifier
            }

            // Dim disabled content; controls also drop interactivity via their
            // own `enabled` parameter (e.g. Button).
            "disabled" -> {
                val off = (entry.args["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content == "true"
                if (off) modifier.alpha(0.38f) else modifier
            }

            else -> modifier // unknown modifier: ignore, never crash rendering
        }
    }
    return modifier
}

// Always-called animated wrappers: the underlying Animatable persists across
// recompositions, so a later tween eases from wherever the value currently is.

@Composable
private fun animatedDp(value: Dp, spec: AnimSpec?): Dp =
    animateDpAsState(value, animationSpec(spec), label = "dp").value

@Composable
private fun animatedFloat(value: Float, spec: AnimSpec?): Float =
    animateFloatAsState(value, animationSpec(spec), label = "float").value

@Composable
private fun animatedColor(value: Color, spec: AnimSpec?): Color =
    animateColorAsState(value, animationSpec(spec), label = "color").value

private fun <T> animationSpec(spec: AnimSpec?): AnimationSpec<T> = when {
    spec == null -> snap()
    spec.curve == "spring" -> spring()
    else -> tween(spec.durationMs, easing = easingFor(spec.curve))
}

private fun easingFor(curve: String): Easing = when (curve) {
    "linear" -> LinearEasing
    "easeIn" -> CubicBezierEasing(0.42f, 0f, 1f, 1f)
    "easeOut" -> CubicBezierEasing(0f, 0f, 0.58f, 1f)
    else -> CubicBezierEasing(0.42f, 0f, 0.58f, 1f) // easeInOut
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
