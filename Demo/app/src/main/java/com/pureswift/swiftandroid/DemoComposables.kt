package com.pureswift.swiftandroid

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import android.widget.RatingBar
import com.pureswift.swiftui.ComposableRegistry

/// Registers the demo app's custom composables into the interpreter's registry.
/// Called once before the first render. This is exactly what an app author
/// does to expose a native Android view or a Compose function to SwiftUI.
fun registerDemoComposables() {

    // A native Android widget (android.widget.RatingBar) bridged through
    // Compose's AndroidView — the canonical "custom Android view" case.
    ComposableRegistry.register("RatingBar") { props, _ ->
        val rating = props.float("rating") ?: 0f
        val max = props.int("max") ?: 5
        AndroidView(
            factory = { context ->
                RatingBar(context).apply {
                    numStars = max
                    stepSize = 0.5f
                    setIsIndicator(true)
                }
            },
            update = { bar ->
                bar.numStars = max
                bar.rating = rating
            },
        )
    }

    // A pure Compose function drawing a dashed border around whatever SwiftUI
    // child content is passed into the slot.
    ComposableRegistry.register("DashedBorder") { props, children ->
        val color = props.color("color") ?: Color(0xFF6750A4.toInt())
        Box(
            modifier = Modifier
                .drawBehind {
                    drawRoundRect(
                        color = color,
                        style = Stroke(
                            width = 5f,
                            pathEffect = PathEffect.dashPathEffect(floatArrayOf(24f, 14f)),
                        ),
                        cornerRadius = CornerRadius(20f, 20f),
                    )
                }
                .padding(18.dp),
        ) {
            children()
        }
    }
}
