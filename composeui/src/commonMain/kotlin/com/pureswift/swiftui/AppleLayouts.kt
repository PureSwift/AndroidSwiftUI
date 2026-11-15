package com.pureswift.swiftui

import androidx.compose.animation.core.Animatable
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.layout.layoutId
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import kotlin.math.max
import kotlin.math.roundToInt

// SwiftUI layouts Compose has no direct match for: `Grid` with `GridRow`s,
// and a list row's `swipeActions`.

/// The text of a node's first `Text` descendant: an action button's title.
internal fun firstText(node: ViewNode): String {
    if (node.type == "Text") return node.string("text") ?: ""
    for (child in node.children) {
        val text = firstText(child)
        if (text.isNotEmpty()) return text
    }
    return ""
}

// MARK: - Grid

private data class GridCell(val row: Int, val column: Int)

private data class GridSpan(val row: Int)

/// SwiftUI's `Grid`: each `GridRow`'s cells in columns as wide as their
/// widest cell, and any other child as a row spanning every column.
/// `horizontal` aligns cells in their column (leading, center, trailing);
/// a row's `alignment` aligns them in the row (top, center, bottom).
@Composable
internal fun RenderAppleGrid(node: ViewNode) {
    val density = LocalDensity.current
    val horizontalSpacing = with(density) { (node.double("horizontalSpacing") ?: 8.0).dp.roundToPx() }
    val verticalSpacing = with(density) { (node.double("verticalSpacing") ?: 8.0).dp.roundToPx() }
    val horizontal = node.string("horizontal") ?: "center"
    val rows = node.children
    val alignments = rows.map { row -> if (row.type == "GridRow") row.string("alignment") ?: "center" else "center" }
    Layout(
        modifier = node.composeModifiers(),
        content = {
            rows.forEachIndexed { r, row ->
                if (row.type == "GridRow") {
                    row.children.forEachIndexed { c, cell ->
                        Box(Modifier.layoutId(GridCell(r, c))) { RenderChild(cell) }
                    }
                } else {
                    Box(Modifier.layoutId(GridSpan(r))) { RenderChild(row) }
                }
            }
        },
    ) { measurables, constraints ->
        val loose = constraints.copy(minWidth = 0, minHeight = 0)
        val placeables = measurables.map { it.layoutId to it.measure(loose) }
        val columns = placeables.maxOfOrNull { (id, _) -> ((id as? GridCell)?.column ?: -1) + 1 } ?: 0
        val widths = IntArray(columns)
        val heights = IntArray(rows.size)
        for ((id, placeable) in placeables) {
            when (id) {
                is GridCell -> {
                    widths[id.column] = max(widths[id.column], placeable.width)
                    heights[id.row] = max(heights[id.row], placeable.height)
                }
                is GridSpan -> heights[id.row] = max(heights[id.row], placeable.height)
            }
        }
        val columnsWidth = widths.sum() + horizontalSpacing * max(0, columns - 1)
        val spanWidth = placeables.filter { it.first is GridSpan }.maxOfOrNull { it.second.width } ?: 0
        val width = max(columnsWidth, spanWidth).coerceIn(constraints.minWidth, constraints.maxWidth)
        val tops = IntArray(rows.size)
        for (r in 1 until rows.size) tops[r] = tops[r - 1] + heights[r - 1] + verticalSpacing
        val height = ((if (rows.isEmpty()) 0 else tops.last() + heights.last()))
            .coerceIn(constraints.minHeight, constraints.maxHeight)
        val lefts = IntArray(columns)
        for (c in 1 until columns) lefts[c] = lefts[c - 1] + widths[c - 1] + horizontalSpacing
        fun x(left: Int, room: Int, size: Int) = when (horizontal) {
            "leading" -> left
            "trailing" -> left + room - size
            else -> left + (room - size) / 2
        }
        fun y(row: Int, size: Int) = when (alignments[row]) {
            "top", "firstTextBaseline" -> tops[row]
            "bottom", "lastTextBaseline" -> tops[row] + heights[row] - size
            else -> tops[row] + (heights[row] - size) / 2
        }
        layout(width, height) {
            for ((id, placeable) in placeables) {
                when (id) {
                    is GridCell -> placeable.place(x(lefts[id.column], widths[id.column], placeable.width), y(id.row, placeable.height))
                    is GridSpan -> placeable.place(x(0, width, placeable.width), y(id.row, placeable.height))
                }
            }
        }
    }
}

// MARK: - Swipe actions

/// A row with SwiftUI's `swipeActions`: the first child is the row, the
/// rest its `Button` actions. Dragging from `edge` (trailing by default)
/// reveals the actions; with `allowsFullSwipe` (the default), a drag past
/// most of the row runs the first. TalkBack offers the actions on the row
/// itself, so the row stays one stop, and the hidden buttons aren't stops
/// at all.
@Composable
internal fun RenderSwipeActions(node: ViewNode) {
    val content = node.children.firstOrNull() ?: return
    val actions = node.children.drop(1).filter { it.long("onTap") != null }
    val leading = node.string("edge") == "leading"
    val fullSwipe = node.string("allowsFullSwipe") != "false"
    val density = LocalDensity.current
    val actionWidth = with(density) { 80.dp.toPx() }
    val revealed = actionWidth * actions.size
    val offset = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()
    val rowWidth = remember { FloatArray(1) }
    val direction = if (leading) 1f else -1f

    fun run(action: ViewNode) {
        scope.launch { offset.animateTo(0f) }
        action.long("onTap")?.let { SwiftBridge.sink.invokeVoid(it) }
    }

    // Full width, as a list row is: the whole row can be swiped.
    Box(
        modifier = node.composeModifiers()
            .fillMaxWidth()
            .clipToBounds()
            .onSizeChanged { rowWidth[0] = it.width.toFloat() }
            .semantics {
                customActions = actions.map { action ->
                    CustomAccessibilityAction(firstText(action)) { run(action); true }
                }
            },
    ) {
        // The actions, under the row, out of the accessibility tree: the row
        // carries them as custom actions.
        Row(
            modifier = Modifier.matchParentSize().clearAndSetSemantics { },
            horizontalArrangement = if (leading) Arrangement.Start else Arrangement.End,
        ) {
            for (action in actions) {
                val destructive = action.string("role") == "destructive"
                val tint = action.modifiers.firstOrNull { it.kind == "tint" }?.args?.long("color")?.let { Color(it.toInt()) }
                Box(
                    modifier = Modifier
                        .width(80.dp)
                        .fillMaxHeight()
                        .background(tint ?: if (destructive) Color(0xFFFF3B30) else Color(0xFF8E8E93))
                        .clickable { run(action) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(firstText(action), color = Color.White, fontSize = 15.sp, modifier = Modifier.padding(horizontal = 8.dp))
                }
            }
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .offset { IntOffset(offset.value.roundToInt(), 0) }
                .background(MaterialTheme.colorScheme.surface)
                .pointerInput(actions.size, leading) {
                    detectHorizontalDragGestures(
                        onDragEnd = {
                            val distance = offset.value * direction
                            scope.launch {
                                when {
                                    fullSwipe && actions.isNotEmpty() && distance > rowWidth[0] * 0.6f -> run(actions.first())
                                    distance > revealed / 2 -> offset.animateTo(revealed * direction)
                                    else -> offset.animateTo(0f)
                                }
                            }
                        },
                        onDragCancel = { scope.launch { offset.animateTo(0f) } },
                    ) { change, amount ->
                        change.consume()
                        val limit = if (fullSwipe) rowWidth[0] else revealed
                        val next = (offset.value + amount) * direction
                        scope.launch { offset.snapTo(next.coerceIn(0f, limit) * direction) }
                    }
                },
        ) {
            RenderChild(content)
        }
    }
}
