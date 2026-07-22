package com.pureswift.swiftandroid

import android.widget.CompoundButton

class CompoundButtonOnCheckedChangeListener(val action: SwiftObject): CompoundButton.OnCheckedChangeListener {

    external override fun onCheckedChanged(button: CompoundButton, isChecked: Boolean)
}
