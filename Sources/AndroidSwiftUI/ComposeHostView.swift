//
//  ComposeHostView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// Hosts Jetpack Compose content inside an Android view hierarchy.
///
/// The content parameter must implement the `com.pureswift.swiftandroid.ComposeContent` interface.
@JavaClass("com.pureswift.swiftandroid.ComposeHostView")
open class ComposeHostView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(_ context: AndroidContent.Context?, _ content: JavaObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getContent() -> JavaObject?

    /// Forces the hosted content to recompose.
    @JavaMethod
    open func refresh()
}
