package com.pureswift.swiftui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import kotlinx.serialization.json.Json

/// Holds the current node tree as Compose state. Swift assigns a new tree per
/// update; `@Immutable` nodes with structural equality mean recomposition is
/// proportional to changed subtrees, not tree size.
class TreeStore {

    var root: ViewNode? by mutableStateOf(null)
        private set

    /// Swift assigns a freshly materialized tree.
    fun update(node: ViewNode?) {
        root = node
    }

    /// Debug/fixture path: accepts the Swift side's JSON dump.
    fun updateJson(json: String) {
        root = Json.decodeFromString<ViewNode>(json)
    }
}

/// Receives UI events from the interpreter. The bridge (R4) provides an
/// implementation backed by `external` functions dispatching into Swift; the
/// desktop rig and tests install logging or recording sinks.
interface CallbackSink {
    fun invokeVoid(id: Long)
    fun invokeBool(id: Long, value: Boolean)
    fun invokeDouble(id: Long, value: Double)
    fun invokeInt(id: Long, value: Int)
    fun invokeString(id: Long, value: String)
    /// Resolves a lazy row on demand; the logging default has no rows.
    fun itemNode(id: Long, index: Int): ViewNode? = null
}

/// Global event sink used by the interpreter. Defaults to a logger.
object SwiftBridge {

    var sink: CallbackSink = LoggingCallbackSink

    object LoggingCallbackSink : CallbackSink {
        override fun invokeVoid(id: Long) = println("SwiftBridge.invokeVoid($id)")
        override fun invokeBool(id: Long, value: Boolean) = println("SwiftBridge.invokeBool($id, $value)")
        override fun invokeDouble(id: Long, value: Double) = println("SwiftBridge.invokeDouble($id, $value)")
        override fun invokeInt(id: Long, value: Int) = println("SwiftBridge.invokeInt($id, $value)")
        override fun invokeString(id: Long, value: String) = println("SwiftBridge.invokeString($id, $value)")
        override fun itemNode(id: Long, index: Int): ViewNode? = null
    }
}
