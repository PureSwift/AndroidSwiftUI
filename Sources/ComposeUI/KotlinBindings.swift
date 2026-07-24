//
//  KotlinBindings.swift
//  ComposeUI
//
//  Swift→Kotlin bindings for the interpreter's node model. This is the safe
//  bridge direction: methods resolve by name+signature lookup and fail loudly
//  on mismatch.
//

import SwiftJava

/// Binding for `com.pureswift.swiftui.ViewNode`.
@JavaClass("com.pureswift.swiftui.ViewNode")
open class ViewNodeObject: JavaObject {

    /// The bridge constructor: one JNI call per node, arrays crossing as
    /// single arguments. Prop/modifier-arg values are JSON literals; negative
    /// count/provider mean "absent".
    @JavaMethod
    @_nonoverride public convenience init(
        _ type: String,
        _ id: String,
        _ propKeys: [String],
        _ propValues: [String],
        _ modifierKinds: [String],
        _ modifierArgs: [String],
        _ children: [ViewNodeObject?],
        _ count: Int32,
        _ itemProviderId: Int64,
        environment: JNIEnvironment? = nil
    )
}

/// Binding for `com.pureswift.swiftui.TreeStore`.
@JavaClass("com.pureswift.swiftui.TreeStore")
open class TreeStore: JavaObject {

    /// Assigns a freshly materialized tree; Compose recomposes changed subtrees.
    @JavaMethod
    open func update(_ node: ViewNodeObject?)
}
