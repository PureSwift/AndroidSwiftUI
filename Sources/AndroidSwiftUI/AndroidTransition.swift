//
//  AndroidTransition.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// The animation applied to a hosted Android view when it is mounted and unmounted.
enum AndroidViewTransition: Equatable {

    /// No animation.
    case none

    /// Slide in from the trailing edge, out to the trailing edge (navigation push and pop).
    case slide

    /// Slide up from the bottom edge, back down on removal (sheet presentation).
    case cover

    /// Fade in and out (scrims).
    case fade
}

/// An Android view whose appearance and removal are animated by the renderer.
protocol AndroidTransitioningView {

    var transition: AndroidViewTransition { get }
}

extension AndroidViewTransition {

    /// The duration of mount and unmount animations, in milliseconds.
    static var duration: Int64 { 250 }

    /// Sets the initial state and animates the view into place.
    ///
    /// Called immediately after the view is added to its parent; the property animator
    /// starts on the next frame, so the initial state is visible first.
    func animateAppearance(of view: AndroidView.View) {
        guard let animator = view.animate() else { return }
        switch self {
        case .none:
            return
        case .slide:
            view.setTranslationX(Float(screenSize(of: view).width))
            _ = animator.translationX(0)
        case .cover:
            view.setTranslationY(Float(screenSize(of: view).height))
            _ = animator.translationY(0)
        case .fade:
            view.setAlpha(0)
            _ = animator.alpha(1)
        }
        _ = animator.setDuration(Self.duration)
    }

    /// Animates the view out, invoking `completion` when the animation finishes.
    ///
    /// For `none`, the completion is invoked immediately.
    func animateRemoval(of view: AndroidView.View, completion: @escaping () -> ()) {
        guard self != .none, let animator = view.animate() else {
            completion()
            return
        }
        switch self {
        case .none:
            return
        case .slide:
            _ = animator.translationX(Float(screenSize(of: view).width))
        case .cover:
            _ = animator.translationY(Float(screenSize(of: view).height))
        case .fade:
            _ = animator.alpha(0)
        }
        let endAction = Runnable(completion)
        _ = animator
            .setDuration(Self.duration)
            .withEndAction(endAction.as(JavaLang.Runnable.self))
    }

    private func screenSize(of view: AndroidView.View) -> (width: Int32, height: Int32) {
        guard let metrics = view.getContext()?.getResources()?.getDisplayMetrics() else {
            return (width: 1080, height: 1920)
        }
        return (width: metrics.widthPixels, height: metrics.heightPixels)
    }
}
