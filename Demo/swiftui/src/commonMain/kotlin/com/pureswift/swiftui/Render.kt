package com.pureswift.swiftui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.core.MutableTransitionState
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyHorizontalGrid
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.RadioButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ProgressIndicatorDefaults
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.SwitchDefaults
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
import androidx.compose.material3.rememberModalBottomSheetState
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
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
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
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.ImeAction
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

// Inherited style environment (SwiftUI's `.font`/`.foregroundColor`/`.disabled`
// set values for a whole subtree). A node folds its own such modifiers into
// these before rendering its children; leaves consume them as defaults that
// their own modifiers still override.
internal val LocalInheritedFontSize = compositionLocalOf { TextUnit.Unspecified }
internal val LocalInheritedFontWeight = compositionLocalOf<FontWeight?> { null }
internal val LocalInheritedColor = compositionLocalOf { Color.Unspecified }
internal val LocalInheritedDisabled = compositionLocalOf { false }
internal val LocalTint = compositionLocalOf<Color?> { null }

// Control styles inherit like the text attributes above: a style set on a
// container applies to every matching control in its subtree.
internal val LocalButtonStyle = compositionLocalOf { "automatic" }
internal val LocalPickerStyle = compositionLocalOf { "automatic" }
internal val LocalToggleStyle = compositionLocalOf { "automatic" }
internal val LocalTextFieldStyle = compositionLocalOf { "automatic" }
internal val LocalLabelStyle = compositionLocalOf { "automatic" }

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
fun Render(node: ViewNode) = RenderChild(node)

/// The real entry point, shared by the public `Render` and the composable
/// registry's child slot. The registry MUST call this directly rather than the
/// public `Render`: a nested call to a public composable from a dynamically-
/// invoked factory slot has its restart group skipped by the Compose runtime,
/// so the whole subtree silently fails to compose. Routing through this
/// internal function composes reliably. It also folds the node's own style
/// modifiers into the inherited environment so its subtree sees them.
@Composable
internal fun RenderChild(node: ViewNode) {
    val spec = node.string("animationCurve")?.let {
        AnimSpec(it, (node.double("animationDurationMs") ?: 350.0).toInt())
    } ?: LocalAnimationSpec.current

    var fontSize = LocalInheritedFontSize.current
    var fontWeight = LocalInheritedFontWeight.current
    var color = LocalInheritedColor.current
    var disabled = LocalInheritedDisabled.current
    var tint = LocalTint.current
    var buttonStyle = LocalButtonStyle.current
    var pickerStyle = LocalPickerStyle.current
    var toggleStyle = LocalToggleStyle.current
    var textFieldStyle = LocalTextFieldStyle.current
    var labelStyle = LocalLabelStyle.current
    for (m in node.modifiers) {
        when (m.kind) {
            "font" -> {
                m.args.string("style")?.let {
                    fontSize = fontSizeForStyle(it).sp
                    fontWeight = defaultWeightForStyle(it)
                }
                m.args.double("size")?.let { fontSize = it.sp }
                m.args.string("weight")?.let { fontWeight = fontWeightFor(it) }
            }
            "fontWeight" -> m.args.string("weight")?.let { fontWeight = fontWeightFor(it) }
            "foregroundColor" -> m.args.long("color")?.let { color = Color(it.toInt()) }
            "disabled" -> if ((m.args["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content == "true") disabled = true
            "tint" -> m.args.long("color")?.let { tint = Color(it.toInt()) }
            "buttonStyle" -> m.args.string("style")?.let { buttonStyle = it }
            "pickerStyle" -> m.args.string("style")?.let { pickerStyle = it }
            "toggleStyle" -> m.args.string("style")?.let { toggleStyle = it }
            "textFieldStyle" -> m.args.string("style")?.let { textFieldStyle = it }
            "labelStyle" -> m.args.string("style")?.let { labelStyle = it }
        }
    }

    CompositionLocalProvider(
        LocalAnimationSpec provides spec,
        LocalInheritedFontSize provides fontSize,
        LocalInheritedFontWeight provides fontWeight,
        LocalInheritedColor provides color,
        LocalInheritedDisabled provides disabled,
        LocalTint provides tint,
        LocalButtonStyle provides buttonStyle,
        LocalPickerStyle provides pickerStyle,
        LocalToggleStyle provides toggleStyle,
        LocalTextFieldStyle provides textFieldStyle,
        LocalLabelStyle provides labelStyle,
    ) { RenderResolved(node) }
}

@Composable
private fun RenderResolved(node: ViewNode) {
    key(node.id) {
        RenderEffects(node)
        when (node.type) {
            "Text" -> RenderText(node)

            "Button" -> RenderButton(node)

            "Toggle" -> RenderToggle(node)

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
                RenderZStackChildren(node)
            }

            // Outside a stack, a Spacer has no axis to expand along; render as empty.
            "Spacer" -> Spacer(modifier = node.composeModifiers())

            "Divider" -> HorizontalDivider(modifier = node.composeModifiers())

            "ScrollView" -> {
                // A lazy stack scrolls itself, and nesting it inside a scrolling
                // parent would measure it with unbounded height (a Compose
                // crash), so hand the scrolling over to it.
                val lone = node.children.singleOrNull { !it.isPresentation() }
                if (lone != null && lone.isLazyStack()) {
                    RenderChild(lone)
                } else {
                    val state = rememberScrollState()
                    if (node.string("axis") == "horizontal") {
                        Row(modifier = node.composeModifiers().horizontalScroll(state)) { RenderChildren(node) }
                    } else {
                        Column(modifier = node.composeModifiers().verticalScroll(state)) { RenderChildren(node) }
                    }
                }
            }

            "DisclosureGroup" -> RenderDisclosureGroup(node)

            "Label" -> RenderLabel(node)

            "Link" -> RenderLink(node)

            "GeometryReader" -> RenderGeometryReader(node)

            "LazyVStack" -> RenderLazyStack(node, vertical = true)
            "LazyHStack" -> RenderLazyStack(node, vertical = false)

            // A Color greedily fills the space offered it (SwiftUI semantics);
            // fillMaxWidth is applied after the chain so an explicit frame width
            // still constrains it.
            "Color" -> Box(
                modifier = node.composeModifiers()
                    .fillMaxWidth()
                    .background(Color((node.long("color") ?: 0).toInt()))
            )

            "Image" -> RenderImage(node)

            "AsyncImage" -> RenderAsyncImage(node)

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

            "VideoPlayer" -> RenderVideoPlayer(node)

            "ProgressView" -> RenderProgressView(node)

            "Slider" -> {
                val onChange = node.long("onChange")
                val min = (node.double("min") ?: 0.0).toFloat()
                val max = (node.double("max") ?: 1.0).toFloat()
                val tint = LocalTint.current
                Slider(
                    value = (node.double("value") ?: 0.0).toFloat(),
                    onValueChange = { onChange?.let { id -> SwiftBridge.sink.invokeDouble(id, it.toDouble()) } },
                    valueRange = min..max,
                    enabled = node.isEnabled(),
                    colors = if (tint != null) SliderDefaults.colors(thumbColor = tint, activeTrackColor = tint) else SliderDefaults.colors(),
                    modifier = node.composeModifiers().fillMaxWidth(),
                )
            }

            "TextField" -> RenderTextField(node)

            "Stepper" -> RenderStepper(node)

            "ContextMenu" -> RenderContextMenu(node)

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
// Determinacy (is there a value?) and shape (progressViewStyle) are separate
// axes; the default picks a shape from determinacy, matching the original
// value-only behavior. A label, when present, sits beneath the indicator.
@Composable
private fun RenderProgressView(node: ViewNode) {
    val value = node.double("value")
    val tint = LocalTint.current
    val style = node.modifiers.firstOrNull { it.kind == "progressViewStyle" }?.args?.string("style")
    val circular = when (style) {
        "circular" -> true
        "linear" -> false
        else -> value == null          // automatic
    }
    val label = node.children.filter { !it.isPresentation() }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = node.composeModifiers(),
    ) {
        when {
            circular && value != null -> CircularProgressIndicator(
                progress = { value.toFloat() },
                color = tint ?: ProgressIndicatorDefaults.circularColor,
            )
            circular -> CircularProgressIndicator(
                color = tint ?: ProgressIndicatorDefaults.circularColor,
            )
            value != null -> LinearProgressIndicator(
                progress = { value.toFloat() },
                color = tint ?: ProgressIndicatorDefaults.linearColor,
                modifier = Modifier.fillMaxWidth(),
            )
            else -> LinearProgressIndicator(
                color = tint ?: ProgressIndicatorDefaults.linearColor,
                modifier = Modifier.fillMaxWidth(),
            )
        }
        if (label.isNotEmpty()) {
            Spacer(modifier = Modifier.height(6.dp))
            label.forEach { RenderChild(it) }
        }
    }
}

// The inherited style picks the button's presentation; `plain`/`borderless`
// drop the container so only the label shows, as they do on iOS.
@Composable
private fun RenderButton(node: ViewNode) {
    val onTap = node.long("onTap")
    val tint = LocalTint.current
    val click = { onTap?.let { SwiftBridge.sink.invokeVoid(it) }; Unit }
    val enabled = node.isEnabled()
    val modifier = node.composeModifiers()
    val content: @Composable RowScope.() -> Unit = { RenderChildren(node) }

    when (LocalButtonStyle.current) {
        "plain", "borderless" -> TextButton(
            onClick = click,
            enabled = enabled,
            colors = if (tint != null) ButtonDefaults.textButtonColors(contentColor = tint) else ButtonDefaults.textButtonColors(),
            modifier = modifier,
            content = content,
        )
        "bordered" -> OutlinedButton(
            onClick = click,
            enabled = enabled,
            colors = if (tint != null) ButtonDefaults.outlinedButtonColors(contentColor = tint) else ButtonDefaults.outlinedButtonColors(),
            modifier = modifier,
            content = content,
        )
        // automatic and borderedProminent are both the filled button
        else -> Button(
            onClick = click,
            enabled = enabled,
            colors = if (tint != null) ButtonDefaults.buttonColors(containerColor = tint) else ButtonDefaults.buttonColors(),
            modifier = modifier,
            content = content,
        )
    }
}

// switch (default), checkbox, or a toggling button.
@Composable
private fun RenderToggle(node: ViewNode) {
    val onChange = node.long("onChange")
    val tint = LocalTint.current
    val isOn = node.bool("isOn") ?: false
    val enabled = node.isEnabled()
    val set = { value: Boolean -> onChange?.let { SwiftBridge.sink.invokeBool(it, value) }; Unit }

    if (LocalToggleStyle.current == "button") {
        // a button whose selected state is the toggle's value
        FilterChip(
            selected = isOn,
            onClick = { set(!isOn) },
            enabled = enabled,
            label = { RenderChildren(node) },
            modifier = node.composeModifiers(),
        )
        return
    }
    Row(verticalAlignment = Alignment.CenterVertically, modifier = node.composeModifiers()) {
        RenderChildren(node)
        when (LocalToggleStyle.current) {
            "checkbox" -> Checkbox(
                checked = isOn,
                onCheckedChange = { set(it) },
                enabled = enabled,
                colors = if (tint != null) CheckboxDefaults.colors(checkedColor = tint) else CheckboxDefaults.colors(),
            )
            else -> Switch(
                checked = isOn,
                onCheckedChange = { set(it) },
                enabled = enabled,
                colors = if (tint != null) SwitchDefaults.colors(checkedTrackColor = tint) else SwitchDefaults.colors(),
            )
        }
    }
}

// Reports the size the PARENT offers, never the content's own size — that is
// what keeps measurement from feeding back into itself. Swift ignores a report
// equal to what it already holds, so a settled layout reports once and stops.
@Composable
private fun RenderGeometryReader(node: ViewNode) {
    val onSize = node.long("onSize")
    BoxWithConstraints(modifier = node.composeModifiers().fillMaxWidth()) {
        val width = maxWidth.value.toDouble()
        // an unbounded height (inside a scrolling parent) isn't a real offer;
        // report 0 so the content can fall back rather than see infinity
        val height = if (constraints.hasBoundedHeight) maxHeight.value.toDouble() else 0.0
        LaunchedEffect(width, height) {
            onSize?.let { SwiftBridge.sink.invokeString(it, "$width,$height") }
        }
        RenderChildren(node)
    }
}

// Handing the address to the platform's UriHandler keeps the whole hop out of
// Swift — no callback, no bridge entry. The label takes the accent colour so it
// reads as a link, unless something upstream already tinted it.
@Composable
private fun RenderLink(node: ViewNode) {
    val url = node.string("url")
    val handler = LocalUriHandler.current
    val accent = LocalTint.current ?: MaterialTheme.colorScheme.primary
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = node.composeModifiers().clickable(enabled = url != null && node.isEnabled()) {
            // a malformed or unhandled address must not take the app down
            url?.let { runCatching { handler.openUri(it) } }
        },
    ) {
        CompositionLocalProvider(LocalInheritedColor provides accent) {
            RenderChildren(node)
        }
    }
}

// children are [icon, title]; the inherited label style may drop either half.
@Composable
private fun RenderLabel(node: ViewNode) {
    val icon = node.children.getOrNull(0)
    val title = node.children.getOrNull(1)
    val style = LocalLabelStyle.current
    val showIcon = style != "titleOnly"
    val showTitle = style != "iconOnly"
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        modifier = node.composeModifiers(),
    ) {
        if (showIcon) icon?.let { RenderChild(it) }
        if (showTitle) title?.let { RenderChild(it) }
    }
}

// A tappable header (label + chevron) over collapsible content. Expansion is
// interpreter-local unless a binding is present, in which case the tap
// round-trips through Swift like any other control.
@Composable
private fun RenderDisclosureGroup(node: ViewNode) {
    val labelCount = node.long("labelCount")?.toInt() ?: 0
    val onToggle = node.long("onToggle")
    val bound = node.props.containsKey("isExpanded")

    var localExpanded by remember(node.id) { mutableStateOf(false) }
    val expanded = if (bound) node.string("isExpanded") == "true" else localExpanded

    Column(modifier = node.composeModifiers().fillMaxWidth()) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth().clickable {
                if (bound) onToggle?.let { SwiftBridge.sink.invokeBool(it, !expanded) }
                else localExpanded = !localExpanded
            }.padding(vertical = 6.dp),
        ) {
            Row(modifier = Modifier.weight(1f)) {
                node.children.take(labelCount).forEach { RenderChild(it) }
            }
            Icon(
                imageVector = if (expanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
                contentDescription = if (expanded) "Collapse" else "Expand",
            )
        }
        if (expanded) {
            Column(modifier = Modifier.fillMaxWidth().padding(start = 12.dp)) {
                node.children.drop(labelCount).forEach { RenderChild(it) }
            }
        }
    }
}

private fun ViewNode.isPresentation(): Boolean =
    type == "Sheet" || type == "Alert" || type == "ConfirmationDialog" || type == "ToolbarItem"

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
    // `.focused` binding: Swift drives focus through `isFocused`, and the field
    // reports back when the user moves focus themselves.
    val focus = node.modifiers.firstOrNull { it.kind == "focused" }
    val shouldFocus = focus?.args?.string("isFocused") == "true"
    val onFocusChange = focus?.args?.long("onChange")
    val requester = remember(node.id) { FocusRequester() }
    val focusManager = LocalFocusManager.current
    var hasFocus by remember(node.id) { mutableStateOf(false) }

    var fieldModifier = node.composeModifiers().fillMaxWidth()
    if (focus != null) {
        fieldModifier = fieldModifier
            .focusRequester(requester)
            .onFocusChanged { state ->
                if (state.isFocused != hasFocus) {
                    hasFocus = state.isFocused
                    onFocusChange?.let { SwiftBridge.sink.invokeBool(it, state.isFocused) }
                }
            }
    }

    val change: (TextFieldValue) -> Unit = { v ->
        local = v
        if (v.text != lastSent) {
            lastSent = v.text
            onChange?.let { SwiftBridge.sink.invokeString(it, v.text) }
        }
    }
    val label: @Composable () -> Unit = { Text(node.string("placeholder") ?: "") }
    val transformation = if (node.bool("secure") == true) PasswordVisualTransformation() else VisualTransformation.None

    // .keyboardType chooses the key layout; .submitLabel names the action key.
    val keyboardType = when (node.modifiers.firstOrNull { it.kind == "keyboardType" }?.args?.string("type")) {
        "numberPad", "asciiCapableNumberPad" -> KeyboardType.Number
        "decimalPad" -> KeyboardType.Decimal
        "phonePad", "namePhonePad" -> KeyboardType.Phone
        "emailAddress" -> KeyboardType.Email
        "URL" -> KeyboardType.Uri
        else -> KeyboardType.Text
    }
    val imeAction = when (node.modifiers.firstOrNull { it.kind == "submitLabel" }?.args?.string("label")) {
        "search", "webSearch" -> ImeAction.Search
        "go", "route" -> ImeAction.Go
        "send" -> ImeAction.Send
        "next" -> ImeAction.Next
        "join", "continue", "return" -> ImeAction.Done
        else -> ImeAction.Default
    }
    val keyboardOptions = KeyboardOptions(keyboardType = keyboardType, imeAction = imeAction)

    // .onSubmit fires on the keyboard action key, whatever its label.
    val onSubmit = node.modifiers.firstOrNull { it.kind == "onSubmit" }?.args?.long("action")
    val keyboardActions = KeyboardActions(
        onDone = { onSubmit?.let { SwiftBridge.sink.invokeVoid(it) } },
        onGo = { onSubmit?.let { SwiftBridge.sink.invokeVoid(it) } },
        onSend = { onSubmit?.let { SwiftBridge.sink.invokeVoid(it) } },
        onSearch = { onSubmit?.let { SwiftBridge.sink.invokeVoid(it) } },
        onNext = { onSubmit?.let { SwiftBridge.sink.invokeVoid(it) } },
    )

    // plain drops the box outline; roundedBorder and automatic keep it
    if (LocalTextFieldStyle.current == "plain") {
        TextField(
            value = local,
            onValueChange = change,
            label = label,
            enabled = node.isEnabled(),
            visualTransformation = transformation,
            keyboardOptions = keyboardOptions,
            keyboardActions = keyboardActions,
            singleLine = true,
            colors = TextFieldDefaults.colors(
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
            ),
            modifier = fieldModifier,
        )
    } else {
        OutlinedTextField(
            value = local,
            onValueChange = change,
            label = label,
            enabled = node.isEnabled(),
            visualTransformation = transformation,
            keyboardOptions = keyboardOptions,
            keyboardActions = keyboardActions,
            singleLine = true,
            modifier = fieldModifier,
        )
    }

    if (focus != null) {
        LaunchedEffect(shouldFocus) {
            if (shouldFocus && !hasFocus) requester.requestFocus()
            else if (!shouldFocus && hasFocus) focusManager.clearFocus()
        }
    }
}

// Label, then − / + edge buttons pushed to the trailing side.
@Composable
private fun RenderStepper(node: ViewNode) {
    val onIncrement = node.long("onIncrement")
    val onDecrement = node.long("onDecrement")
    val enabled = node.isEnabled()
    Row(verticalAlignment = Alignment.CenterVertically, modifier = node.composeModifiers().fillMaxWidth()) {
        RenderChildren(node)
        Spacer(modifier = Modifier.weight(1f))
        TextButton(onClick = { onDecrement?.let { SwiftBridge.sink.invokeVoid(it) } }, enabled = enabled) { Text("−", fontSize = 20.sp) }
        TextButton(onClick = { onIncrement?.let { SwiftBridge.sink.invokeVoid(it) } }, enabled = enabled) { Text("+", fontSize = 20.sp) }
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
        TextButton(onClick = { showDialog = true }, enabled = node.isEnabled()) { Text(formatDateMillis(millis)) }
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

// Formats the selection in the device locale's medium date style (e.g.
// "Jul 23, 2026", "23 juil. 2026", "2026/07/23"). UTC matches the epoch-millis
// the DatePicker and Foundation's Date both use.
private fun formatDateMillis(millis: Long): String {
    val format = java.text.DateFormat.getDateInstance(java.text.DateFormat.MEDIUM)
    format.timeZone = java.util.TimeZone.getTimeZone("UTC")
    return format.format(java.util.Date(millis))
}

// Long-press the content to reveal a dropdown of the menu items. children are
// [content..., menuItem...]; contentCount splits them.
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun RenderContextMenu(node: ViewNode) {
    val contentCount = node.long("contentCount")?.toInt() ?: 0
    var expanded by remember { mutableStateOf(false) }
    Box {
        Column(
            modifier = node.composeModifiers().combinedClickable(
                onClick = {},
                onLongClick = { expanded = true },
            )
        ) {
            node.children.take(contentCount).forEach { RenderChild(it) }
        }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            for (child in node.children.drop(contentCount)) {
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

// A trigger button opening a dropdown; each child Button becomes a menu item
// firing its own tap callback.
@Composable
private fun RenderMenu(node: ViewNode) {
    var expanded by remember { mutableStateOf(false) }
    Box {
        TextButton(onClick = { expanded = true }, enabled = node.isEnabled()) { Text(node.string("label") ?: "") }
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
    val enabled = node.isEnabled()
    val select = { value: String -> onChange?.let { SwiftBridge.sink.invokeString(it, value) }; Unit }
    val title = node.string("title") ?: ""

    when (LocalPickerStyle.current) {
        // a segmented control: every option visible at once
        "segmented" -> Column(modifier = node.composeModifiers().fillMaxWidth()) {
            if (title.isNotEmpty()) Text(title)
            SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
                options.forEachIndexed { index, (value, label) ->
                    SegmentedButton(
                        selected = value == selection,
                        onClick = { select(value) },
                        enabled = enabled,
                        shape = SegmentedButtonDefaults.itemShape(index, options.size),
                    ) { Text(label) }
                }
            }
        }
        // inline: the options laid out in place as a selectable list
        "inline" -> Column(modifier = node.composeModifiers().fillMaxWidth()) {
            if (title.isNotEmpty()) Text(title)
            for ((value, label) in options) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth().clickable(enabled = enabled) { select(value) },
                ) {
                    RadioButton(selected = value == selection, onClick = { select(value) }, enabled = enabled)
                    Text(label)
                }
            }
        }
        // automatic and menu: the label opens a dropdown
        else -> Row(modifier = node.composeModifiers().fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(title)
            Spacer(modifier = Modifier.weight(1f))
            TextButton(onClick = { expanded = true }, enabled = enabled) { Text(currentLabel) }
            DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                for ((value, label) in options) {
                    DropdownMenuItem(text = { Text(label) }, onClick = {
                        expanded = false
                        select(value)
                    })
                }
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
    val slots = rememberTransitionSlots(node)
    val spec = LocalAnimationSpec.current
    for ((child, slot) in orderedTransitionChildren(node, slots)) {
        key(child.id) {
            when {
                child.type == "Spacer" -> Spacer(modifier = Modifier.weight(1f))
                slot != null -> AnimatedVisibility(slot.state, enter = enterFor(child, spec), exit = exitFor(child, spec)) { Render(child) }
                else -> Render(child)
            }
        }
    }
}

@Composable
private fun RowScope.RenderRowChildren(node: ViewNode) {
    val slots = rememberTransitionSlots(node)
    val spec = LocalAnimationSpec.current
    for ((child, slot) in orderedTransitionChildren(node, slots)) {
        key(child.id) {
            when {
                child.type == "Spacer" -> Spacer(modifier = Modifier.weight(1f))
                slot != null -> AnimatedVisibility(slot.state, enter = enterFor(child, spec), exit = exitFor(child, spec)) { Render(child) }
                else -> Render(child)
            }
        }
    }
}

// ZStack children, with transition support.
@Composable
private fun RenderZStackChildren(node: ViewNode) {
    val slots = rememberTransitionSlots(node)
    val spec = LocalAnimationSpec.current
    for ((child, slot) in orderedTransitionChildren(node, slots)) {
        key(child.id) {
            if (slot != null) {
                AnimatedVisibility(slot.state, enter = enterFor(child, spec), exit = exitFor(child, spec)) { Render(child) }
            } else {
                Render(child)
            }
        }
    }
}

// --- Transitions: a child with `.transition()` animates as it appears/leaves ---

private fun ViewNode.transition(): ModifierNode? = modifiers.firstOrNull { it.kind == "transition" }
private fun ViewNode.hasTransition(): Boolean = transition() != null

// A slot keeps an exiting child's node and visibility state alive after it has
// left the tree, so its exit animation can play out.
private class TransitionSlot(var node: ViewNode, val state: MutableTransitionState<Boolean>)

@Composable
private fun rememberTransitionSlots(node: ViewNode): Map<String, TransitionSlot> {
    val slots = remember { mutableStateMapOf<String, TransitionSlot>() }
    val presentIds = node.children.filter { !it.isPresentation() && it.hasTransition() }.mapTo(HashSet()) { it.id }
    node.children.filter { !it.isPresentation() && it.hasTransition() }.forEach { child ->
        val slot = slots[child.id]
        if (slot == null) {
            slots[child.id] = TransitionSlot(child, MutableTransitionState(false).apply { targetState = true })
        } else {
            slot.node = child
            slot.state.targetState = true
        }
    }
    val finished = mutableListOf<String>()
    slots.forEach { (id, slot) ->
        if (id !in presentIds) {
            slot.state.targetState = false                       // begin exit
            if (slot.state.isIdle && !slot.state.currentState) finished += id  // exit done
        }
    }
    finished.forEach { slots.remove(it) }
    return slots
}

// The children to render, in order: present children (each paired with its
// transition slot if it has one), then any exiting slots not in the tree — so a
// transition child is rendered at ONE stable call site (keyed by id) whether
// present or exiting, letting Compose animate the handoff instead of tearing it
// down.
private fun orderedTransitionChildren(
    node: ViewNode,
    slots: Map<String, TransitionSlot>,
): List<Pair<ViewNode, TransitionSlot?>> {
    val present = node.children.filter { !it.isPresentation() }
    val presentIds = present.mapTo(HashSet()) { it.id }
    val result = present.map { it to slots[it.id] }
    val exiting = slots.entries.filter { it.key !in presentIds }.map { it.value.node to it.value }
    return result + exiting
}

private fun enterFor(node: ViewNode, spec: AnimSpec?): EnterTransition {
    val d = spec?.durationMs ?: 300
    return when (node.transition()?.args?.string("kind")) {
        "opacity" -> fadeIn(tween(d))
        "scale" -> scaleIn(tween(d)) + fadeIn(tween(d))
        "slide" -> slideInHorizontally(tween(d)) { it } + fadeIn(tween(d))
        "move" -> when (node.transition()?.args?.string("edge")) {
            "top" -> slideInVertically(tween(d)) { -it }
            "bottom" -> slideInVertically(tween(d)) { it }
            "leading" -> slideInHorizontally(tween(d)) { -it }
            else -> slideInHorizontally(tween(d)) { it }
        }
        "identity" -> EnterTransition.None
        else -> fadeIn(tween(d))
    }
}

private fun exitFor(node: ViewNode, spec: AnimSpec?): ExitTransition {
    val d = spec?.durationMs ?: 300
    return when (node.transition()?.args?.string("kind")) {
        "opacity" -> fadeOut(tween(d))
        "scale" -> scaleOut(tween(d)) + fadeOut(tween(d))
        "slide" -> slideOutHorizontally(tween(d)) { it } + fadeOut(tween(d))
        "move" -> when (node.transition()?.args?.string("edge")) {
            "top" -> slideOutVertically(tween(d)) { -it }
            "bottom" -> slideOutVertically(tween(d)) { it }
            "leading" -> slideOutHorizontally(tween(d)) { -it }
            else -> slideOutHorizontally(tween(d)) { it }
        }
        "identity" -> ExitTransition.None
        else -> fadeOut(tween(d))
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
    val taskMod = node.modifiers.firstOrNull { it.kind == "task" }
    val taskStart = taskMod?.args?.long("start")
    val taskCancel = taskMod?.args?.long("cancel")
    val onChange = node.modifiers.firstOrNull { it.kind == "onChange" }

    if (onAppear != null || onDisappear != null) {
        DisposableEffect(Unit) {
            onAppear?.let { SwiftBridge.sink.invokeVoid(it) }
            onDispose { onDisappear?.let { SwiftBridge.sink.invokeVoid(it) } }
        }
    }
    if (taskStart != null && taskCancel != null) {
        // The cancel id changes each evaluation; onDispose can fire generations
        // after appear, so hand it the freshest id (kept in a remembered holder)
        // — still resolvable, and it cancels by stable path regardless.
        val cancelHolder = remember { longArrayOf(taskCancel) }
        cancelHolder[0] = taskCancel
        DisposableEffect(Unit) {
            SwiftBridge.sink.invokeVoid(taskStart)
            onDispose { SwiftBridge.sink.invokeVoid(cancelHolder[0]) }
        }
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

// A control is enabled unless its own `.disabled(true)` or an inherited one
// (from an ancestor container) is in scope.
@Composable
private fun ViewNode.isEnabled(): Boolean = !isDisabled() && !LocalInheritedDisabled.current

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
        return
    }
    val asset = node.string("name")?.let { rememberAssetPainter(it) }
    if (asset != null) {
        androidx.compose.foundation.Image(
            painter = asset,
            contentDescription = node.string("name"),
            contentScale = node.imageContentScale(),
            modifier = node.composeModifiers(),
        )
    } else {
        Text("[${node.string("name") ?: "image"}]", modifier = node.composeModifiers())
    }
}

// resizable() unlocks scaling; the contentMode modifier then picks fit or fill.
private fun ViewNode.imageContentScale(): ContentScale {
    if (string("resizable") != "true") return ContentScale.Inside
    return when (modifiers.firstOrNull { it.kind == "contentMode" }?.args?.string("mode")) {
        "fit" -> ContentScale.Fit
        "fill" -> ContentScale.Crop
        else -> ContentScale.FillBounds   // bare resizable stretches, as in SwiftUI
    }
}

// Fetch → decode → swap in, entirely Compose-side: a spinner while loading and
// a labeled placeholder on failure. Keyed by URL so a new URL reloads.
@Composable
private fun RenderAsyncImage(node: ViewNode) {
    val url = node.string("url")
    if (url == null) {
        Text("[image]", modifier = node.composeModifiers())
        return
    }
    // Seed from the cache synchronously: a URL already fetched renders on the
    // first frame with no spinner. Only a miss touches the network.
    var bitmap by remember(url) { mutableStateOf(ImageCache.get(url)) }
    var failed by remember(url) { mutableStateOf(false) }
    LaunchedEffect(url) {
        if (bitmap != null) return@LaunchedEffect
        val loaded = loadRemoteImage(url)
        if (loaded != null) {
            ImageCache.put(url, loaded)
            bitmap = loaded
        } else {
            failed = true
        }
    }
    val image = bitmap
    when {
        image != null -> androidx.compose.foundation.Image(
            bitmap = image,
            contentDescription = url,
            contentScale = node.imageContentScale(),
            modifier = node.composeModifiers(),
        )
        failed -> Text("[failed: $url]", modifier = node.composeModifiers())
        else -> Box(contentAlignment = Alignment.Center, modifier = node.composeModifiers()) {
            CircularProgressIndicator()
        }
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
    // Start from the inherited environment; the node's own modifiers override.
    var color = LocalInheritedColor.current
    var fontSize: TextUnit = LocalInheritedFontSize.current
    var weight: FontWeight? = LocalInheritedFontWeight.current
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
@OptIn(ExperimentalFoundationApi::class)
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

            "frame" -> foldFrame(modifier, entry, spec)

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

            // Tap and long press share one detector: two competing pointer
            // handlers on the same view would fight over the gesture.
            "onTapGesture" -> {
                val id = entry.args.long("action")
                val longID = modifiers.firstOrNull { it.kind == "longPress" }?.args?.long("action")
                when {
                    id == null -> modifier
                    longID == null -> modifier.clickable { SwiftBridge.sink.invokeVoid(id) }
                    else -> modifier.combinedClickable(
                        onClick = { SwiftBridge.sink.invokeVoid(id) },
                        onLongClick = { SwiftBridge.sink.invokeVoid(longID) },
                    )
                }
            }

            "longPress" -> {
                val id = entry.args.long("action")
                // already wired above when this view also has a tap handler
                val hasTap = modifiers.any { it.kind == "onTapGesture" }
                if (id == null || hasTap) modifier
                else modifier.combinedClickable(onClick = {}, onLongClick = { SwiftBridge.sink.invokeVoid(id) })
            }

            // Continuous drag: positions are reported in points, converted from
            // the pointer's pixels, as "<phase>;<startX>,<startY>;<x>,<y>".
            "drag" -> {
                val id = entry.args.long("action")
                if (id == null) modifier else {
                // The detector is a long-running coroutine, so it must be keyed
                // by the node's STABLE id: keying by the callback id would tear
                // the gesture down mid-drag, since every onChanged re-evaluates
                // the tree and mints a fresh id. The lambda then reads the id
                // from a holder so it never dispatches to a reclaimed callback.
                val latest = remember(this@composeModifiers.id) { longArrayOf(id) }
                latest[0] = id
                modifier.pointerInput(this@composeModifiers.id) {
                    var start = Offset.Zero
                    // Accumulate per-event deltas rather than reading absolute
                    // positions: a view that offsets itself by the translation
                    // moves under the finger, and absolute readings would
                    // compensate for that motion and collapse toward zero.
                    var total = Offset.Zero
                    fun payload(phase: String): String {
                        val end = start + total
                        return "$phase;${start.x.toDp().value},${start.y.toDp().value};" +
                            "${end.x.toDp().value},${end.y.toDp().value}"
                    }
                    detectDragGestures(
                        onDragStart = { start = it; total = Offset.Zero },
                        onDrag = { change, dragAmount ->
                            change.consume()
                            total += dragAmount
                            SwiftBridge.sink.invokeString(latest[0], payload("changed"))
                        },
                        // ends carrying the final translation, as SwiftUI does
                        onDragEnd = { SwiftBridge.sink.invokeString(latest[0], payload("ended")) },
                        onDragCancel = { SwiftBridge.sink.invokeString(latest[0], payload("ended")) },
                    )
                }
                }
            }

            // Accessibility folds into Compose semantics rather than changing
            // any visual property.
            "accessibilityLabel" -> {
                val text = entry.args.string("text")
                if (text == null) modifier else modifier.semantics { contentDescription = text }
            }

            "accessibilityValue" -> {
                val text = entry.args.string("text")
                if (text == null) modifier else modifier.semantics { stateDescription = text }
            }

            // clearAndSetSemantics drops this node AND its subtree from the
            // tree, which is what hiding has to mean for a container.
            "accessibilityHidden" -> {
                val hidden = entry.args.string("value") == "true"
                if (hidden) modifier.clearAndSetSemantics { } else modifier
            }

            "accessibilityAddTraits" -> {
                val traits = (entry.args["traits"] as? kotlinx.serialization.json.JsonArray)
                    ?.mapNotNull { (it as? kotlinx.serialization.json.JsonPrimitive)?.content }
                    .orEmpty()
                modifier.semantics {
                    if (traits.contains("button")) role = Role.Button
                    if (traits.contains("image")) role = Role.Image
                    if (traits.contains("header")) heading()
                    if (traits.contains("selected")) selected = true
                }
            }

            // A test handle, never announced.
            "accessibilityIdentifier" -> {
                val id = entry.args.string("id")
                if (id == null) modifier else modifier.testTag(id)
            }


            // Dim disabled content; controls also drop interactivity via their
            // own `enabled` parameter (e.g. Button).
            "disabled" -> {
                val off = (entry.args["value"] as? kotlinx.serialization.json.JsonPrimitive)?.content == "true"
                if (off) modifier.alpha(0.38f) else modifier
            }

            else -> modifier // consumed elsewhere (Text/RenderChild/effects) or unknown
        }
    }
    // Schema-drift visibility: a kind no consumer recognizes gets a red outline,
    // the modifier-level analog of the unknown-node diagnostic.
    if (modifiers.any { it.kind !in KNOWN_MODIFIER_KINDS }) {
        modifier = modifier.border(1.dp, Color.Red)
    }
    return modifier
}

// Every modifier kind some consumer handles — composeModifiers folds most;
// the rest are read by RenderText, RenderChild (environment), RenderEffects, or
// container branches (tag/tabItem). A kind outside this set is schema drift.
private val KNOWN_MODIFIER_KINDS = setOf(
    "padding", "frame", "background", "cornerRadius", "offset", "rotation",
    "scale", "opacity", "border", "shadow", "clipShape", "onTapGesture", "disabled",
    "font", "fontWeight", "italic", "foregroundColor", "lineLimit", "multilineTextAlignment",
    "tint", "onAppear", "onDisappear", "task", "onChange", "animation", "tag", "tabItem",
    "transition", "focused", "longPress", "drag", "contentMode", "progressViewStyle",
    "buttonStyle", "pickerStyle", "toggleStyle", "textFieldStyle",
    "accessibilityLabel", "accessibilityValue", "accessibilityHidden",
    "accessibilityAddTraits", "accessibilityIdentifier", "keyboardType", "submitLabel", "onSubmit", "labelStyle",
)

// Folds a frame entry: fixed size, fill (maxWidth/Height .infinity), bounded
// (widthIn/heightIn), and content alignment within the resulting box.
@Composable
private fun foldFrame(base: Modifier, entry: ModifierNode, spec: AnimSpec?): Modifier {
    var m = base
    val fixedW = entry.args.double("width")
    val fixedH = entry.args.double("height")
    val minW = entry.args.double("minWidth")
    val maxW = entry.args.double("maxWidth")
    val minH = entry.args.double("minHeight")
    val maxH = entry.args.double("maxHeight")
    val fillW = entry.args.bool("fillWidth") == true
    val fillH = entry.args.bool("fillHeight") == true

    when {
        fixedW != null -> m = m.width(animatedDp(fixedW.dp, spec))
        fillW -> m = m.fillMaxWidth()
        minW != null || maxW != null -> m = m.widthIn(
            min = minW?.dp ?: Dp.Unspecified,
            max = maxW?.dp ?: Dp.Unspecified,
        )
    }
    when {
        fixedH != null -> m = m.height(animatedDp(fixedH.dp, spec))
        fillH -> m = m.fillMaxHeight()
        minH != null || maxH != null -> m = m.heightIn(
            min = minH?.dp ?: Dp.Unspecified,
            max = maxH?.dp ?: Dp.Unspecified,
        )
    }
    val h = entry.args.string("horizontal")
    val v = entry.args.string("vertical")
    if (h != null || v != null) {
        m = m.wrapContentSize(frameAlignment(h ?: "center", v ?: "center"))
    }
    return m
}

private fun frameAlignment(horizontal: String, vertical: String): Alignment = when (vertical to horizontal) {
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
    val screen = node.children.getOrNull(topIndex)
    val toolbar = screen?.children?.filter { it.type == "ToolbarItem" }.orEmpty()
    fun placed(vararg names: String) = toolbar.filter { (it.string("placement") ?: "automatic") in names }
    val leading = placed("navigationBarLeading")
    // an unplaced item goes to the trailing side, as it does on iOS
    val trailing = placed("navigationBarTrailing", "automatic")
    val principal = placed("principal")
    val bottom = placed("bottomBar")

    Scaffold(
        topBar = {
            val title = titles.getOrNull(topIndex).orEmpty()
            if (title.isNotEmpty() || depth > 1 || toolbar.isNotEmpty()) {
                TopAppBar(
                    title = {
                        // a principal item replaces the title outright
                        if (principal.isNotEmpty()) principal.forEach { RenderToolbarItem(it) }
                        else Text(title)
                    },
                    navigationIcon = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (depth > 1) {
                                IconButton(onClick = { onPop?.let { SwiftBridge.sink.invokeVoid(it) } }) {
                                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                                }
                            }
                            leading.forEach { RenderToolbarItem(it) }
                        }
                    },
                    actions = { trailing.forEach { RenderToolbarItem(it) } },
                )
            }
        },
        bottomBar = {
            if (bottom.isNotEmpty()) {
                BottomAppBar {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
                    ) { bottom.forEach { RenderToolbarItem(it) } }
                }
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
                node.searchField(index)?.let { RenderSearchField(it, index) }
                node.children.getOrNull(index)?.let { Render(it) }
            }
        }
    }
    RenderSheetsAndAlerts(node.children.getOrNull(topIndex))
}

private class SearchFieldSpec(val text: String, val callbackId: Long, val prompt: String)

// A screen's `searchable` descriptor: [text, callbackId, prompt], or an empty
// array when that screen declared none.
private fun ViewNode.searchField(index: Int): SearchFieldSpec? {
    val searches = props["searches"] as? kotlinx.serialization.json.JsonArray ?: return null
    val entry = searches.getOrNull(index) as? kotlinx.serialization.json.JsonArray ?: return null
    if (entry.size < 3) return null
    val text = (entry[0] as? kotlinx.serialization.json.JsonPrimitive)?.content ?: ""
    val id = (entry[1] as? kotlinx.serialization.json.JsonPrimitive)?.content?.toLongOrNull() ?: return null
    val prompt = (entry[2] as? kotlinx.serialization.json.JsonPrimitive)?.content ?: ""
    return SearchFieldSpec(text, id, prompt)
}

// Same uncontrolled-with-reconciliation scheme as RenderTextField, keyed by the
// stable screen index (the callback id churns each evaluation, so it can't key
// the remembered cursor state).
@Composable
private fun RenderSearchField(spec: SearchFieldSpec, index: Int) {
    var local by remember(index) { mutableStateOf(TextFieldValue(spec.text)) }
    var lastSent by remember(index) { mutableStateOf(spec.text) }
    if (spec.text != lastSent) {
        local = TextFieldValue(spec.text, selection = androidx.compose.ui.text.TextRange(spec.text.length))
        lastSent = spec.text
    }
    OutlinedTextField(
        value = local,
        onValueChange = { v ->
            local = v
            if (v.text != lastSent) {
                lastSent = v.text
                SwiftBridge.sink.invokeString(spec.callbackId, v.text)
            }
        },
        placeholder = { Text(spec.prompt.ifEmpty { "Search" }) },
        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
        singleLine = true,
        modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 4.dp),
    )
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

// A toolbar item's content, lifted out of the screen body into the bar.
@Composable
private fun RenderToolbarItem(item: ViewNode) {
    item.children.forEach { RenderChild(it) }
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
                // Detents were emitted but never read, so every sheet wrapped its
                // content and a "full-size" sheet came up as a short strip.
                val detents = child.stringArray("detents")
                val medium = detents.contains("medium")
                val large = detents.isEmpty() || detents.contains("large")
                ModalBottomSheet(
                    onDismissRequest = { onDismiss?.let { SwiftBridge.sink.invokeVoid(it) } },
                    // with no medium detent there is no partial stop to rest at
                    sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = !medium),
                ) {
                    // A Material sheet is only as tall as its content, so one that
                    // should own the screen has to be told to fill it.
                    val height = when {
                        medium && !large -> Modifier.fillMaxHeight(0.5f)
                        else -> Modifier.fillMaxHeight()
                    }
                    Box(modifier = height) {
                        child.children.firstOrNull()?.let { Render(it) }
                    }
                }
            }
            "Alert" -> RenderAlert(child)
            "ConfirmationDialog" -> RenderConfirmationDialog(child)
        }
    }
}

// An action sheet: a title/message header and one vertical button per choice,
// destructive choices in the error color, presented from the bottom edge.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RenderConfirmationDialog(node: ViewNode) {
    val onDismiss = node.long("onDismiss")
    val buttons = (node.props["buttons"] as? kotlinx.serialization.json.JsonArray) ?: kotlinx.serialization.json.JsonArray(emptyList())
    val parsed = buttons.mapNotNull { entry ->
        val arr = entry as? kotlinx.serialization.json.JsonArray ?: return@mapNotNull null
        val title = (arr[0] as? kotlinx.serialization.json.JsonPrimitive)?.content ?: return@mapNotNull null
        val role = (arr[1] as? kotlinx.serialization.json.JsonPrimitive)?.content ?: "normal"
        val id = (arr[2] as? kotlinx.serialization.json.JsonPrimitive)?.content?.toLongOrNull() ?: return@mapNotNull null
        Triple(title, role, id)
    }
    ModalBottomSheet(onDismissRequest = { onDismiss?.let { SwiftBridge.sink.invokeVoid(it) } }) {
        Column(modifier = Modifier.fillMaxWidth().padding(bottom = 24.dp)) {
            val header = node.string("message")
            if (node.string("showsTitle") == "true") {
                Text(
                    node.string("title") ?: "",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
                )
            }
            if (header != null) {
                Text(
                    header,
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
                )
            }
            for ((title, role, id) in parsed) {
                TextButton(
                    onClick = { SwiftBridge.sink.invokeVoid(id) },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(
                        title,
                        color = if (role == "destructive") MaterialTheme.colorScheme.error else Color.Unspecified,
                    )
                }
            }
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


private fun ViewNode.isLazyStack(): Boolean = type == "LazyVStack" || type == "LazyHStack"

// A lazy stack fetches only the elements Compose asks for, one JNI call each.
// Content that wasn't a single ForEach carries no provider and renders eagerly.
@Composable
private fun RenderLazyStack(node: ViewNode, vertical: Boolean) {
    val provider = node.long("itemProvider")
    if (provider == null) {
        if (vertical) Column(modifier = node.composeModifiers()) { RenderChildren(node) }
        else Row(modifier = node.composeModifiers()) { RenderChildren(node) }
        return
    }
    val count = node.count ?: 0
    val keys = node.stringArray("keys")
    val spacing = (node.double("spacing") ?: 0.0).dp
    if (vertical) {
        LazyColumn(
            modifier = node.composeModifiers().fillMaxWidth(),
            horizontalAlignment = when (node.string("alignment")) {
                "leading" -> Alignment.Start
                "trailing" -> Alignment.End
                else -> Alignment.CenterHorizontally
            },
            verticalArrangement = Arrangement.spacedBy(spacing),
        ) {
            items(count = count, key = { keys.getOrNull(it) ?: it }) { index ->
                val element = remember(provider, index) { SwiftBridge.sink.itemNode(provider, index) }
                element?.let { RenderChild(it) }
            }
        }
    } else {
        LazyRow(
            modifier = node.composeModifiers(),
            verticalAlignment = when (node.string("alignment")) {
                "top" -> Alignment.Top
                "bottom" -> Alignment.Bottom
                else -> Alignment.CenterVertically
            },
            horizontalArrangement = Arrangement.spacedBy(spacing),
        ) {
            items(count = count, key = { keys.getOrNull(it) ?: it }) { index ->
                val element = remember(provider, index) { SwiftBridge.sink.itemNode(provider, index) }
                element?.let { RenderChild(it) }
            }
        }
    }
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
