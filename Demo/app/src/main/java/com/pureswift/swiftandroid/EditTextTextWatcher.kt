package com.pureswift.swiftandroid

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText

class EditTextTextWatcher(val action: SwiftObject): TextWatcher {

    /// Registers itself on the field. `TextWatcher` has no Swift binding, so the
    /// registration happens here rather than from Swift.
    fun attach(editText: EditText) {
        editText.addTextChangedListener(this)
    }

    override fun beforeTextChanged(text: CharSequence?, start: Int, count: Int, after: Int) { }

    override fun onTextChanged(text: CharSequence?, start: Int, before: Int, count: Int) {
        onTextChangedSwift(text?.toString() ?: "")
    }

    override fun afterTextChanged(editable: Editable?) { }

    external fun onTextChangedSwift(text: String)
}
