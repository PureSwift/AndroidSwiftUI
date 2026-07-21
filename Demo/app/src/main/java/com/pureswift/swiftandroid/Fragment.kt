package com.pureswift.swiftandroid

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout

// Framework fragment whose view creation and lifecycle are forwarded to a Swift implementation.
@Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
class Fragment(private val swiftObject: SwiftObject?) : android.app.Fragment() {

    init {
        NativeLibrary.shared()
    }

    // required by the system for fragment recreation
    constructor() : this(null)

    fun getSwiftObject(): SwiftObject? = swiftObject

    override fun onCreateView(inflater: LayoutInflater?, container: ViewGroup?, savedInstanceState: Bundle?): View {
        return FrameLayout(activity)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        onViewCreatedSwift(view, savedInstanceState)
    }

    external fun onViewCreatedSwift(view: View?, savedInstanceState: Bundle?)

    override fun onStart() {
        super.onStart()
        onStartSwift()
    }

    external fun onStartSwift()

    override fun onResume() {
        super.onResume()
        onResumeSwift()
    }

    external fun onResumeSwift()

    override fun onPause() {
        super.onPause()
        onPauseSwift()
    }

    external fun onPauseSwift()

    override fun onStop() {
        super.onStop()
        onStopSwift()
    }

    external fun onStopSwift()

    override fun onDestroyView() {
        super.onDestroyView()
        onDestroyViewSwift()
    }

    external fun onDestroyViewSwift()
}
