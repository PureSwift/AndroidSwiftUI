//
//  AndroidSlider.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

/// The number of steps a continuous slider is divided into, since `SeekBar` reports whole
/// numbers while `Slider` works in a floating point range.
private let continuousSteps: Int32 = 10_000

extension Slider: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidSeekBar(
            value: valueBinding,
            bounds: bounds,
            step: step,
            onEditingChanged: onEditingChanged
        ))
    }
}

/// Native seek bar bound to a `Double` within a range.
struct AndroidSeekBar {

    @Binding
    var value: Double

    let bounds: ClosedRange<Double>

    let step: _SliderStep

    let onEditingChanged: (Bool) -> ()
}

extension AndroidSeekBar: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.SeekBar {
        let view = AndroidWidget.SeekBar(context.androidContext)
        // a seek bar that hugs its content collapses to the thumb and can't be dragged, so
        // it spans the stack instead; the renderer preserves parameters set here
        view.setLayoutParams(ViewGroup.LayoutParams(
            try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT,
            try! JavaClass<ViewGroup.LayoutParams>().WRAP_CONTENT
        ))
        view.setMax(stepCount)
        let listener = SeekBarOnSeekBarChangeListener { progress in
            let newValue = self.value(forProgress: progress)
            guard newValue != self.value else { return }
            self.value = newValue
            self.onEditingChanged(true)
        }
        listener.attach(view)
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.SeekBar, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidSeekBar {

    /// The number of discrete positions the bar offers, matching the slider's step when it
    /// has one so the thumb lands exactly on each value.
    var stepCount: Int32 {
        switch step {
        case .any:
            return continuousSteps
        case let .discrete(stride):
            guard stride > 0 else { return continuousSteps }
            return Int32(((bounds.upperBound - bounds.lowerBound) / stride).rounded())
        }
    }

    func value(forProgress progress: Int32) -> Double {
        let fraction = Double(progress) / Double(stepCount)
        return bounds.lowerBound + fraction * (bounds.upperBound - bounds.lowerBound)
    }

    func progress(forValue value: Double) -> Int32 {
        let span = bounds.upperBound - bounds.lowerBound
        guard span > 0 else { return 0 }
        let fraction = (min(max(value, bounds.lowerBound), bounds.upperBound) - bounds.lowerBound) / span
        return Int32((fraction * Double(stepCount)).rounded())
    }

    func updateView(_ view: AndroidWidget.SeekBar) {
        let progress = progress(forValue: value)
        if view.getProgress() != progress {
            view.setProgress(progress)
        }
    }
}
