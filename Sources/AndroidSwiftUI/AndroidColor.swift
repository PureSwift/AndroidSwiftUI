//
//  AndroidColor.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension Color {

    /// The ARGB color int this color resolves to, given the enclosing environment.
    ///
    /// Resolution is environment-dependent (e.g. `.primary`, `.accentColor`, dynamic
    /// colors), so this reads the environment most recently captured by the renderer
    /// (`RepresentableHostContext`) — the same source `Text`'s own `setTextColor(_:in:)`
    /// uses via `argbBitMask(in:)`, which this reuses.
    var androidColorInt: Int32 {
        Int32(bitPattern: argbBitMask(in: RepresentableHostContext.environment))
    }
}

extension Color: AndroidPrimitive {

    /// A plain, solid-color view — used directly (e.g. as a `.background(Color)`) and as
    /// the building block for `_BackgroundLayout`.
    var renderedBody: AnyView {
        AnyView(_AndroidColorView(color: self))
    }
}

/// Native primitive backing a plain `Color` view: an opaque view filled with the color.
struct _AndroidColorView {
    let color: Color
}

extension _AndroidColorView: AnyAndroidView, _PrimitiveView {

    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view = AndroidView.View(context)
        view.setBackgroundColor(color.androidColorInt)
        return view
    }

    func updateAndroidView(_ view: AndroidView.View) {
        view.setBackgroundColor(color.androidColorInt)
    }

    func removeAndroidView(_ view: AndroidView.View) { }
}
