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
    @_nonoverride public convenience init(environment: JNIEnvironment? = nil)
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
