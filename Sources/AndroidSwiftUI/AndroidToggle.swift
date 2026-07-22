//
//  AndroidToggle.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

/// Renders a toggle as the platform's Material switch.
///
/// `Toggle` reads `EnvironmentValues.toggleStyle` whether or not its body is used, and the
/// key traps unless a renderer supplies a default, so this is registered in
/// `EnvironmentValues.defaultEnvironment`.
struct DefaultToggleStyle: ToggleStyle {

    typealias Body = AndroidSwitch

    func makeBody(configuration: ToggleStyleConfiguration) -> AndroidSwitch {
        AndroidSwitch(isOn: configuration.$isOn, label: configuration.label)
    }
}

/// Material switch bound to a `Bool`, labelled by the toggle's own label.
struct AndroidSwitch {

    @Binding
    var isOn: Bool

    let label: AnyView
}

extension AndroidSwitch: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidMaterial.MaterialSwitch {
        let view = MaterialSwitch(context.androidContext)
        let listener = CompoundButtonOnCheckedChangeListener { isChecked in
            // only write back on a real change, so the binding isn't touched when the
            // reconciler sets the checked state during an update
            guard isChecked != self.isOn else { return }
            self.isOn = isChecked
        }
        view.setOnCheckedChangeListener(listener.as(AndroidWidget.CompoundButton.OnCheckedChangeListener.self))
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: AndroidMaterial.MaterialSwitch, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidSwitch {

    func updateView(_ view: AndroidMaterial.MaterialSwitch) {
        if view.isChecked() != isOn {
            view.setChecked(isOn)
        }
        if let text = mapAnyView(label, transform: { (text: Text) in text }),
           let textView = view.as(AndroidWidget.TextView.self) {
            text.updateTextView(textView)
        }
    }
}
