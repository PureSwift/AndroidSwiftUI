//
//  GridViewAdapter.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

/// Sources the cells of a `ComposeGridView` from the grid's SwiftUI children.
@JavaClass("com.pureswift.swiftandroid.GridViewAdapter")
open class GridViewAdapter: JavaObject {

    @JavaMethod
    @_nonoverride public convenience init(swiftObject: SwiftObject!, environment: JNIEnvironment? = nil)

    @JavaMethod
    func getContext() -> SwiftObject!
}

@JavaImplementation("com.pureswift.swiftandroid.GridViewAdapter")
extension GridViewAdapter {

    @JavaMethod
    func getCount() -> Int32 {
        Int32(context.cells.count)
    }

    @JavaMethod
    func getView(position: Int32, parent: ViewGroup?) -> AndroidView.View? {
        guard let parent, let androidContext = parent.getContext() else {
            assertionFailure()
            return nil
        }
        let cell = context.cells[Int(position)]
        return resolveAndroidViewRecursively(cell)?.createAndroidView(androidContext)
    }
}

extension GridViewAdapter {

    struct Context {

        let cells: [AnyView]
    }

    var context: Context {
        get {
            getContext().valueObject().value as! Context
        }
        set {
            getContext().valueObject().value = newValue
        }
    }
}
