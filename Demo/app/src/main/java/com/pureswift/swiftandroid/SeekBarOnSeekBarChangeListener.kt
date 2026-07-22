package com.pureswift.swiftandroid

import android.widget.SeekBar

class SeekBarOnSeekBarChangeListener(val action: SwiftObject): SeekBar.OnSeekBarChangeListener {

    /// Registers itself on the bar, so Swift does not need a binding for the listener type.
    fun attach(seekBar: SeekBar) {
        seekBar.setOnSeekBarChangeListener(this)
    }

    override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
        onProgressChangedSwift(progress, fromUser)
    }

    override fun onStartTrackingTouch(seekBar: SeekBar) { }

    override fun onStopTrackingTouch(seekBar: SeekBar) { }

    external fun onProgressChangedSwift(progress: Int, fromUser: Boolean)
}
