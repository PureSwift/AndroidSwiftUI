//
//  AndroidProgressView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

/// The scale determinate progress is reported on, since `ProgressBar` works in whole steps
/// while `ProgressView` reports a fraction between zero and one.
private let progressScale: Int32 = 10_000

extension _FractionalProgressView: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidProgressBar(fractionCompleted: fractionCompleted))
    }
}

extension _IndeterminateProgressView: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidProgressBar(fractionCompleted: nil))
    }
}

/// Native progress bar, shown as a horizontal track when the progress is known and as the
/// platform's indeterminate spinner otherwise.
struct AndroidProgressBar {

    let fractionCompleted: Double?
}

extension AndroidProgressBar: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.ProgressBar {
        // the horizontal track is only selectable through a style attribute, so the
        // determinate and indeterminate bars are distinct widgets rather than one widget
        // toggling `setIndeterminate`
        let style = fractionCompleted == nil
            ? try! JavaClass<AndroidR.R.attr>().progressBarStyle
            : try! JavaClass<AndroidR.R.attr>().progressBarStyleHorizontal
        let view = AndroidWidget.ProgressBar(context.androidContext, nil, style)
        view.setMax(progressScale)
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.ProgressBar, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidProgressBar {

    func updateView(_ view: AndroidWidget.ProgressBar) {
        guard let fractionCompleted else {
            view.setIndeterminate(true)
            return
        }
        view.setIndeterminate(false)
        let clamped = min(max(fractionCompleted, 0), 1)
        view.setProgress(Int32((clamped * Double(progressScale)).rounded()))
    }
}
