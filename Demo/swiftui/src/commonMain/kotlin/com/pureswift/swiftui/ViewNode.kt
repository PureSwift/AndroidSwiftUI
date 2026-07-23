package com.pureswift.swiftui

import androidx.compose.runtime.Immutable
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.longOrNull

/// One entry in a node's ordered modifier chain. Order is significant: the
/// interpreter folds the list into a Compose `Modifier` in list order
/// (outermost SwiftUI modifier first).
@Immutable
@Serializable
data class ModifierNode(
    val kind: String,
    val args: JsonObject = JsonObject(emptyMap()),
)

/// A node of the Swift-evaluated view tree.
///
/// `id` is the view's structural identity path — stable across re-evaluation,
/// so Compose identity (`key`, `remember`) is keyed to it and UI state
/// (scroll, cursor, animation) survives updates.
///
/// Immutable with structural equality: assigning a new tree to the store
/// recomposes only subtrees that actually changed.
@Immutable
@Serializable
data class ViewNode(
    val type: String,
    val id: String,
    val props: JsonObject = JsonObject(emptyMap()),
    val modifiers: List<ModifierNode> = emptyList(),
    val children: List<ViewNode> = emptyList(),
    // lazy containers only; present in the schema from day one
    val count: Int? = null,
    val itemProviderId: Long? = null,
) {

    // Typed prop accessors used by the interpreter.

    fun string(key: String): String? = (props[key] as? JsonPrimitive)?.content

    fun double(key: String): Double? = (props[key] as? JsonPrimitive)?.doubleOrNull

    fun bool(key: String): Boolean? = (props[key] as? JsonPrimitive)?.booleanOrNull

    fun long(key: String): Long? = (props[key] as? JsonPrimitive)?.longOrNull
}

internal fun JsonObject.double(key: String): Double? = (this[key] as? JsonPrimitive)?.doubleOrNull

internal fun JsonObject.long(key: String): Long? = (this[key] as? JsonPrimitive)?.longOrNull
