//
//  AndroidXFragment.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// `androidx.fragment.app.Fragment`
@JavaClass("androidx.fragment.app.Fragment")
open class AndroidXFragment: JavaObject {

    @JavaMethod
    open func getId() -> Int32

    @JavaMethod
    open func getActivity() -> AndroidXFragmentActivity!

    @JavaMethod
    open func getParentFragmentManager() -> AndroidXFragmentManager!

    @JavaMethod
    open func isAdded() -> Bool
}

/// `androidx.fragment.app.FragmentManager`
@JavaClass("androidx.fragment.app.FragmentManager")
open class AndroidXFragmentManager: JavaObject {

    @JavaMethod
    open func beginTransaction() -> AndroidXFragmentTransaction!
}

/// `androidx.fragment.app.FragmentTransaction`
@JavaClass("androidx.fragment.app.FragmentTransaction")
open class AndroidXFragmentTransaction: JavaObject {

    @JavaMethod
    open func add(_ containerViewId: Int32, _ fragment: AndroidXFragment?) -> AndroidXFragmentTransaction!

    @JavaMethod
    open func remove(_ fragment: AndroidXFragment?) -> AndroidXFragmentTransaction!

    @JavaMethod
    open func commit() -> Int32

    @JavaMethod
    open func commitAllowingStateLoss() -> Int32
}

/// `androidx.fragment.app.FragmentActivity`
@JavaClass("androidx.fragment.app.FragmentActivity")
open class AndroidXFragmentActivity: AndroidApp.Activity {

    @JavaMethod
    open func getSupportFragmentManager() -> AndroidXFragmentManager!
}
