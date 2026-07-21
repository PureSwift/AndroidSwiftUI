//
//  ComposeListView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

/// SwiftUI `List` backed by a Jetpack Compose `LazyColumn`.
@JavaClass("com.pureswift.swiftandroid.ComposeListView")
open class ComposeListView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(_ context: AndroidContent.Context?, _ adapter: ListViewAdapter?, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getAdapter() -> ListViewAdapter?

    @JavaMethod
    open func refresh()

    /// Sets the action performed by the pull to refresh gesture, or `nil` to disable the gesture.
    @JavaMethod
    open func setOnRefresh(_ action: Runnable?)

    /// Hides the refresh indicator once the refresh action has completed.
    @JavaMethod
    open func endRefreshing()
}
