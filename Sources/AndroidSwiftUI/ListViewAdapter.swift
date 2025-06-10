//
//  ListViewAdapter.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import Foundation
import AndroidKit

@JavaClass("com.pureswift.swiftandroid.ListViewAdapter", extends: ListAdapter.self)
open class ListViewAdapter: JavaObject {
    
    @JavaMethod
    @_nonoverride public convenience init(swiftObject: SwiftObject!, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    func getContext() -> SwiftObject!
}

@JavaImplementation("com.pureswift.swiftandroid.ListViewAdapter")
extension ListViewAdapter {
    
    @JavaMethod
    func hasStableIds() -> Bool {
        true
    }
    
    @JavaMethod
    func isEmpty() -> Bool {
        context.items.isEmpty
    }
    
    @JavaMethod
    func getCount() -> Int32 {
        Int32(context.items.count)
    }

    @JavaMethod
    func getItem(position: Int32) -> JavaObject? {
        JavaString(context.items[Int(position)])
    }
    
    @JavaMethod
    func getItemId(position: Int32) -> Int64 {
        Int64(position)
    }

    @JavaMethod
    func getItemViewType(position: Int32) -> Int32 {
        0
    }

    @JavaMethod
    func getViewTypeCount() -> Int32 {
        1
    }

    @JavaMethod
    func getView(position: Int32, convertView: AndroidView.View?, parent: ViewGroup?) -> AndroidView.View? {
        guard let parent else {
            assertionFailure()
            return nil
        }
        let view = TextView(parent.getContext())
        let item = context.items[Int(position)]
        view.text = item
        return view
    }

    @JavaMethod
    func areAllItemsEnabled() -> Bool {
        true
    }

    @JavaMethod
    func isEnabled(position: Int32) -> Bool {
        true
    }

    @JavaMethod
    func registerDataSetObserver(observer: JavaObject?) {
        
    }

    @JavaMethod
    func unregisterDataSetObserver(observer: JavaObject?) {
        
    }
}

extension ListViewAdapter {
    
    struct Context {
        
        let items: [String]
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

extension ListViewAdapter {
    
    static var logTag: String { "ListViewAdapter" }
    
    static let log = try! JavaClass<AndroidUtil.Log>()
    
    func log(_ string: String) {
        _ = Self.log.d(Self.logTag, string)
    }
    
    func logError(_ string: String) {
        _ = Self.log.e(Self.logTag, string)
    }
}
