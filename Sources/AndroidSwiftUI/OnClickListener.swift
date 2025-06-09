//
//  OnClickListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

@JavaClass("com.pureswift.swiftandroid.ViewOnClickListener", extends: AndroidView.View.OnClickListener.self)
open class ViewOnClickListener: JavaObject {
        
    @JavaMethod
    @_nonoverride public convenience init(id: String, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    func getId() -> String
}

@JavaImplementation("com.pureswift.swiftandroid.ViewOnClickListener")
extension ViewOnClickListener {
    
    @JavaMethod
    func onClick() {
        log("\(self).\(#function) ID \(getId())")
        guard let action else {
            log("\(self).\(#function): No Action Configured")
            return
        }
        Task {
            await MainActor.run {
                action()
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
    
    func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.d(Self.logTag, string)
    }
}
