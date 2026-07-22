//
//  AndroidViewModifier.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

/// A modifier that can imperatively mutate the Android view produced by its content.
///
/// Conforming types are applied by `ModifiedContent`'s `AndroidPrimitive` conformance
/// below, after the content's own view is created or updated. Only modifiers with a
/// direct, effect on a single native view fit this protocol (padding, frame, offset,
/// rotation, scale, clip, opacity); modifiers that composite multiple views together
/// (`.background(_:)`, `.overlay(_:)`) render via their own primitive types instead,
/// since SwiftUI's `body(content:)` for those already expands into a distinct view tree.
public protocol AndroidViewModifier {

    func modifyAndroidView(_ view: AndroidView.View)
}

extension ModifiedContent: AndroidPrimitive where Content: View {

    public var renderedBody: AnyView {
        if let viewModifier = modifier as? AndroidViewModifier,
           let widget = resolveAndroidView(content) {
            return AnyView(_ModifiedAndroidView(inner: widget, modify: viewModifier.modifyAndroidView))
        }
        // `_BackgroundModifier`/`_BackgroundShapeModifier`/`_OverlayModifier` are the only
        // modifiers in this codebase whose real `body(content:)` expands into a distinct
        // view tree rather than passing `content` straight through (confirmed by auditing
        // every `Modifiers/` file) — reproduce that expansion directly, since calling
        // `modifier.body(content:)` requires constructing an opaque `_ViewModifier_Content`
        // this module has no public initializer for.
        if let background = modifier as? _AndroidBackgroundModifierBoxing {
            return AnyView(AndroidCompositingContainer(children: [background.androidBackgroundContent, AnyView(content)]))
        }
        if let overlay = modifier as? _AndroidOverlayModifierBoxing {
            return AnyView(AndroidCompositingContainer(children: [AnyView(content), overlay.androidOverlayContent]))
        }
        // Every other modifier's real `body(content:)` is a trivial `content` passthrough
        // (padding, frame, offset, rotation, scale, clip, opacity, aspect ratio, shadow,
        // zIndex), so returning the unmodified content here exactly matches their intended
        // behavior when there's no Android-side rendering effect to apply.
        return AnyView(content)
    }
}

/// Type-erases `_BackgroundModifier<Background>`/`_BackgroundShapeModifier<Style,Bounds>`
/// regardless of their generic parameters, exposing the view they composite behind content.
protocol _AndroidBackgroundModifierBoxing {
    var androidBackgroundContent: AnyView { get }
}

/// Type-erases `_OverlayModifier<Overlay>`, exposing the view it composites above content.
protocol _AndroidOverlayModifierBoxing {
    var androidOverlayContent: AnyView { get }
}

/// Resolves the `AnyAndroidView` that a (possibly composite-of-primitives) view ultimately
/// renders to, by recursively unwrapping `AndroidPrimitive.renderedBody`. Returns `nil` for
/// views that never bottom out in a primitive (e.g. arbitrary user-defined composite views),
/// in which case the enclosing modifier has no Android-side effect.
func resolveAndroidView<V>(_ view: V) -> (any AnyAndroidView)? {
    if let widget = view as? any AnyAndroidView {
        return widget
    }
    if let primitive = view as? AndroidPrimitive {
        return mapAnyView(primitive.renderedBody, transform: { (widget: AnyAndroidView) in widget })
            ?? resolveAndroidViewRecursively(primitive.renderedBody)
    }
    return nil
}

/// Resolves the `AnyAndroidView` an already-erased `AnyView` ultimately renders to.
/// Exposed (not `private`) so other primitives (e.g. `AndroidCompositingContainer`) can
/// resolve their own `[AnyView]` children imperatively, bypassing the reconciler.
func resolveAndroidViewRecursively(_ view: AnyView) -> (any AnyAndroidView)? {
    if let widget = mapAnyView(view, transform: { (widget: AnyAndroidView) in widget }) {
        return widget
    }
    guard let primitive = mapAnyView(view, transform: { (primitive: AndroidPrimitive) in primitive }) else {
        return nil
    }
    if let widget = mapAnyView(primitive.renderedBody, transform: { (widget: AnyAndroidView) in widget }) {
        return widget
    }
    return resolveAndroidViewRecursively(primitive.renderedBody)
}

/// Wraps the `AnyAndroidView` produced by a `ModifiedContent`'s content, applying the
/// modifier's effect immediately after the content creates or updates its view.
private struct _ModifiedAndroidView: AnyAndroidView {

    let inner: any AnyAndroidView

    let modify: (AndroidView.View) -> ()

    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let view = inner.createAndroidView(context)
        modify(view)
        return view
    }

    func updateAndroidView(_ view: AndroidView.View) {
        inner.updateAndroidView(view)
        modify(view)
    }

    func removeAndroidView(_ view: AndroidView.View) {
        inner.removeAndroidView(view)
    }
}

extension _ModifiedAndroidView: _PrimitiveView {}
