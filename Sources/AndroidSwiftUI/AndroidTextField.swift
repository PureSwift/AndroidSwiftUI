//
//  AndroidTextField.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension TextField: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidEditText(
            text: textBinding,
            placeholder: mapAnyView(AnyView(label), transform: { (text: Text) in text }),
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        ))
    }
}

/// Native editable text bound to a `String`.
struct AndroidEditText {

    @Binding
    var text: String

    let placeholder: Text?

    let onEditingChanged: (Bool) -> ()

    let onCommit: () -> ()
}

extension AndroidEditText: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.EditText {
        let view = AndroidWidget.EditText(context.androidContext)
        let watcher = EditTextTextWatcher { newText in
            guard newText != self.text else { return }
            self.text = newText
        }
        watcher.attach(view)
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.EditText, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidEditText {

    func updateView(_ view: AndroidWidget.EditText) {
        // writing the text back unconditionally would reset the cursor on every keystroke,
        // since the watcher has already applied the user's edit
        if view.text != text {
            view.text = text
        }
        if let placeholder {
            view.setHint(JavaString(_TextProxy(placeholder).rawText).as(CharSequence.self))
        }
    }
}
