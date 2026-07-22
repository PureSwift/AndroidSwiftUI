package com.pureswift.swiftandroid

import android.view.View
import android.widget.AdapterView
import android.widget.Spinner

class SpinnerOnItemSelectedListener(val action: SwiftObject): AdapterView.OnItemSelectedListener {

    /// Registers itself on the spinner, so Swift does not need a binding for the listener type.
    fun attach(spinner: Spinner) {
        spinner.setOnItemSelectedListener(this)
    }

    override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
        onItemSelectedSwift(position)
    }

    override fun onNothingSelected(parent: AdapterView<*>?) { }

    external fun onItemSelectedSwift(position: Int)
}
