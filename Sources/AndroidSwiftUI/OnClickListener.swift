//
//  OnClickListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

@JavaClass("com.pureswift.swiftandroid.ViewOnClickListener", extends: AndroidView.View.OnClickListener.self)
open class ViewOnClickListener: JavaObject {
    
    var action: (() -> ())?
}

@JavaImplementation("com.pureswift.swiftandroid.ViewOnClickListener")
extension ViewOnClickListener {
    
    @JavaMethod
    func onClick() {
        log("\(self).\(#function)")
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

extension ViewOnClickListener {
    
    static var logTag: String { "ViewOnClickListener" }
    
    func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.d(Self.logTag, string)
    }
}
