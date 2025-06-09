//
//  OnClickListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import Foundation
import AndroidKit

@JavaClass("com.pureswift.swiftandroid.ViewOnClickListener", extends: AndroidView.View.OnClickListener.self)
open class ViewOnClickListener: JavaObject {
        
    @JavaMethod
    @_nonoverride public convenience init(id: String, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    func getId() -> String
    
    deinit {
        log("\(self).\(#function) ID \(getId())")
    }
}

@JavaImplementation("com.pureswift.swiftandroid.ViewOnClickListener")
extension ViewOnClickListener {
    
    @JavaMethod
    func onClick() {
        log("\(self).\(#function) ID \(getId())")
        // drain queue
        RunLoop.main.run(until: Date() + 0.01)
        // get action
        guard let action else {
            logError("\(self).\(#function): No Action Configured")
            return
        }
        Task {
            await MainActor.run {
                action()
                log("\(self).\(#function) ID \(getId()) Executed")
            }
        }
    }
}

public extension ViewOnClickListener {
    
    static private(set) var actions: [String: (() -> ())] = [:]
    
    var action: (() -> ())? {
        get {
            Self.actions[getId()]
        } set {
            Self.actions[getId()] = newValue
        }
    }
}

extension ViewOnClickListener {
    
    static var logTag: String { "ViewOnClickListener" }
    
    static let log = try! JavaClass<AndroidUtil.Log>()
    
    func log(_ string: String) {
        
        _ = Self.log.d(Self.logTag, string)
    }
    
    func logError(_ string: String) {
        _ = Self.log.e(Self.logTag, string)
    }
}
