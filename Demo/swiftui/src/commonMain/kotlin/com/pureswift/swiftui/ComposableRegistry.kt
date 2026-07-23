package com.pureswift.swiftui

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import kotlinx.serialization.json.JsonObject

/// The library's single extension point: Kotlin registers named composables;
/// Swift emits a `Composable(name:props:)` node referencing one. A registered
/// factory receives the node's props and its rendered children slot. Entries
/// registered from common code work on both Android and desktop; a factory
/// that wraps an Android-only view simply isn't registered on desktop.
object ComposableRegistry {

    fun interface Factory {
        @Composable
        fun Content(props: JsonObject, children: @Composable () -> Unit)
    }

    private val factories = mutableMapOf<String, Factory>()

    fun register(name: String, factory: Factory) {
        factories[name] = factory
    }

    @Composable
    internal fun Render(node: ViewNode) {
        val name = node.string("name") ?: return
        val factory = factories[name]
        if (factory != null) {
            factory.Content(node.props) {
                for (child in node.children) {
                    Render(child)
                }
            }
        } else {
            Text("⟨unregistered composable: $name⟩", color = Color.Red)
        }
    }
}
