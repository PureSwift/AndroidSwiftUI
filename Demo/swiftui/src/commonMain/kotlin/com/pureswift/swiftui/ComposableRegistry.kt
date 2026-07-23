package com.pureswift.swiftui

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.longOrNull

/// Typed access to a custom composable's props, so app authors read values
/// without touching the underlying JSON layer (or depending on it).
class Props internal constructor(private val json: JsonObject) {
    fun string(key: String): String? = (json[key] as? JsonPrimitive)?.content
    fun double(key: String): Double? = (json[key] as? JsonPrimitive)?.doubleOrNull
    fun float(key: String): Float? = double(key)?.toFloat()
    fun int(key: String): Int? = (json[key] as? JsonPrimitive)?.intOrNull
    fun bool(key: String): Boolean? = (json[key] as? JsonPrimitive)?.booleanOrNull
    /// A color passed from Swift as `PropValue.color(_:)` (an ARGB int).
    fun color(key: String): Color? = (json[key] as? JsonPrimitive)?.longOrNull?.let { Color(it.toInt()) }

    // Actions: a `ComposableView(actions:)` entry arrives as a callback id; each
    // accessor returns a typed lambda that dispatches back to Swift, or null if
    // the key is absent. The factory never sees the id or the bridge.
    fun voidAction(key: String): (() -> Unit)? =
        (json[key] as? JsonPrimitive)?.longOrNull?.let { id -> { SwiftBridge.sink.invokeVoid(id) } }
    fun boolAction(key: String): ((Boolean) -> Unit)? =
        (json[key] as? JsonPrimitive)?.longOrNull?.let { id -> { v -> SwiftBridge.sink.invokeBool(id, v) } }
    fun doubleAction(key: String): ((Double) -> Unit)? =
        (json[key] as? JsonPrimitive)?.longOrNull?.let { id -> { v -> SwiftBridge.sink.invokeDouble(id, v) } }
    fun intAction(key: String): ((Int) -> Unit)? =
        (json[key] as? JsonPrimitive)?.longOrNull?.let { id -> { v -> SwiftBridge.sink.invokeInt(id, v) } }
    fun stringAction(key: String): ((String) -> Unit)? =
        (json[key] as? JsonPrimitive)?.longOrNull?.let { id -> { v -> SwiftBridge.sink.invokeString(id, v) } }
}

/// The library's single extension point: Kotlin registers named composables;
/// Swift emits a `ComposableView(name:props:)` node referencing one. A factory
/// receives typed props and a slot rendering the SwiftUI child content. Entries
/// registered from common code work on both Android and desktop; a factory that
/// wraps an Android-only view simply isn't registered on desktop.
object ComposableRegistry {

    // A registered factory: given props and a slot rendering the SwiftUI child
    // content, it emits composables. Stored as a plain composable function type.
    private val factories = mutableMapOf<String, @Composable (props: Props, children: @Composable () -> Unit) -> Unit>()

    fun register(name: String, factory: @Composable (props: Props, children: @Composable () -> Unit) -> Unit) {
        factories[name] = factory
    }

    @Composable
    internal fun Render(node: ViewNode) {
        val name = node.string("name") ?: return
        val factory = factories[name]
        if (factory != null) {
            factory(Props(node.props)) {
                // RenderChild, not the public Render: a nested call to a public
                // composable from this dynamically-invoked factory slot has its
                // restart group skipped by the runtime and silently renders
                // nothing.
                for (child in node.children) {
                    RenderChild(child)
                }
            }
        } else {
            Text("⟨unregistered composable: $name⟩", color = Color.Red)
        }
    }
}
