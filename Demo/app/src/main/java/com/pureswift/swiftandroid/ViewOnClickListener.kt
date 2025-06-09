package com.pureswift.swiftandroid

import android.view.View

class ViewOnClickListener(val id: String): View.OnClickListener {

    external override fun onClick(view: View)
}