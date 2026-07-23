package com.pureswift.swiftui

import androidx.compose.runtime.Immutable
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonObject
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

    /// Bridge constructor: the Swift materializer builds nodes through this,
    /// crossing JNI with flat arrays (one call per node, arrays as single
    /// arguments). Prop and modifier-arg values arrive as JSON literals
    /// ("\"text\"", "42", "true"), keeping the typed JsonObject model without
    /// per-field JNI calls. Negative count/provider mean "absent".
    constructor(
        type: String,
        id: String,
        propKeys: Array<String>,
        propValues: Array<String>,
        modifierKinds: Array<String>,
        modifierArgs: Array<String>,
        children: Array<ViewNode>,
        count: Int,
        itemProviderId: Long,
    ) : this(
        type = type,
        id = id,
        props = JsonObject(propKeys.indices.associate { propKeys[it] to Json.parseToJsonElement(propValues[it]) }),
        modifiers = modifierKinds.indices.map {
            ModifierNode(modifierKinds[it], Json.parseToJsonElement(modifierArgs[it]).jsonObject)
        },
        children = children.toList(),
        count = if (count >= 0) count else null,
        itemProviderId = if (itemProviderId >= 0) itemProviderId else null,
    )

    // Typed prop accessors used by the interpreter.

    fun string(key: String): String? = (props[key] as? JsonPrimitive)?.content

    fun double(key: String): Double? = (props[key] as? JsonPrimitive)?.doubleOrNull

    fun bool(key: String): Boolean? = (props[key] as? JsonPrimitive)?.booleanOrNull

    fun long(key: String): Long? = (props[key] as? JsonPrimitive)?.longOrNull
}

internal fun JsonObject.double(key: String): Double? = (this[key] as? JsonPrimitive)?.doubleOrNull

internal fun JsonObject.long(key: String): Long? = (this[key] as? JsonPrimitive)?.longOrNull

internal fun JsonObject.string(key: String): String? = (this[key] as? JsonPrimitive)?.content
