//
//  ComposeGridView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

/// SwiftUI `LazyVGrid`/`LazyHGrid` backed by a Jetpack Compose lazy grid.
@JavaClass("com.pureswift.swiftandroid.ComposeGridView")
open class ComposeGridView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(
        _ context: AndroidContent.Context?,
        _ adapter: GridViewAdapter?,
        _ trackCount: Int32,
        _ minItemSize: Float,
        _ spacing: Float,
        _ vertical: Bool,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    open func getAdapter() -> GridViewAdapter?

    @JavaMethod
    open func refresh()
}
