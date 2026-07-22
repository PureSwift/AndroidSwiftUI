//
//  AndroidBackgroundLayout.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension _BackgroundModifier: _AndroidBackgroundModifierBoxing {
    var androidBackgroundContent: AnyView { AnyView(background) }
}

extension _BackgroundShapeModifier: _AndroidBackgroundModifierBoxing {
    var androidBackgroundContent: AnyView { AnyView(shape.fill(style, style: fillStyle)) }
}

extension _BackgroundStyleModifier: _AndroidBackgroundModifierBoxing {
    /// `.background(someShapeStyle)` (no explicit view/shape) is the overload Swift picks
    /// for `.background(Color.x)`, since `Color: ShapeStyle` is more specific than the
    /// `Background: View` overload. Only solid `Color` styles render; other `ShapeStyle`s
    /// (gradients, materials) would need a `Shape`-backed renderer this project doesn't
    /// have yet, so they're skipped rather than rendered incorrectly.
    var androidBackgroundContent: AnyView {
        guard let color = style as? Color else { return AnyView(EmptyView()) }
        return AnyView(color)
    }
}

extension _OverlayModifier: _AndroidOverlayModifierBoxing {
    var androidOverlayContent: AnyView { AnyView(overlay) }
}

/// Native `FrameLayout` compositing an ordered list of views on top of one another —
/// shared by `.background(_:)`/`.overlay(_:)` and `ZStack`. Later children draw on top;
/// alignment is not yet honored (all children fill the container).
///
/// Children are created and attached imperatively in `createAndroidView`/`updateAndroidView`
/// rather than exposed via `ParentView`: this type is frequently reached through
/// `resolveAndroidView` (e.g. when an outer `AndroidViewModifier` like `.rotationEffect()`
/// wraps a `.background()`), which creates the resolved widget directly and never hands it
/// to the reconciler — so `ParentView.children` would simply never get mounted.
struct AndroidCompositingContainer {

    let children: [AnyView]
}

extension AndroidCompositingContainer: View {
    typealias Body = Never
}

extension AndroidCompositingContainer: AnyAndroidView, _PrimitiveView {

    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        let frame = AndroidWidget.FrameLayout(context)
        let matchParent = try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
        for child in children {
            guard let widget = resolveAndroidViewRecursively(child) else { continue }
            let childView = widget.createAndroidView(context)
            childView.setLayoutParams(AndroidWidget.FrameLayout.LayoutParams(matchParent, matchParent).as(ViewGroup.LayoutParams.self))
            frame.addView(childView)
        }
        return frame
    }

    func updateAndroidView(_ view: AndroidView.View) {
        guard let frame = view.as(AndroidWidget.FrameLayout.self),
              let context = frame.getContext() else { return }
        frame.removeAllViews()
        let matchParent = try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
        for child in children {
            guard let widget = resolveAndroidViewRecursively(child) else { continue }
            let childView = widget.createAndroidView(context)
            childView.setLayoutParams(AndroidWidget.FrameLayout.LayoutParams(matchParent, matchParent).as(ViewGroup.LayoutParams.self))
            frame.addView(childView)
        }
    }
}
