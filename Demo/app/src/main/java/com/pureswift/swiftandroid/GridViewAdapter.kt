package com.pureswift.swiftandroid

import android.view.View
import android.view.ViewGroup

// Sources the cells of a `ComposeGridView` from Swift. Mirrors `ListViewAdapter`, but
// vends fully realized views rather than strings, since grid cells are arbitrary content.
class GridViewAdapter(val context: SwiftObject) {

    external fun getCount(): Int

    external fun getView(position: Int, parent: ViewGroup?): View?
}
