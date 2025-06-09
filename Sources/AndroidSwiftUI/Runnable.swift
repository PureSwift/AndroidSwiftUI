//
//  Runnable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import JavaKit
import JavaRuntime
import AndroidKit
import AndroidJavaLang

@JavaClass("com.pureswift.swiftandroid.Runnable", extends: AndroidJavaLang.Runnable.self)
open class Runnable: JavaObject {
    
    private(set) var block: (() -> Void)?
    
    @JavaMethod
    @_nonoverride public convenience init(environment: JNIEnvironment? = nil)
    
    public convenience init(_ block: @escaping () -> Void) {
        self.init(environment: nil)
        self.block = block
    }
    
    deinit {
        log("\(self).\(#function)")
    }
}

@JavaImplementation("com.pureswift.swiftandroid.Runnable")
extension Runnable {
    
    @JavaMethod
    func run() {
        guard let block else {
            logError("\(self).\(#function): No block set")
            return
        }
        block()
        log("\(self).\(#function) Executed")
    }
}

extension Runnable {
    
    static var logTag: String { "Runnable" }
    
    static let log = try! JavaClass<AndroidUtil.Log>()
    
    func log(_ string: String) {
        
        _ = Self.log.d(Self.logTag, string)
    }
    
    func logError(_ string: String) {
        _ = Self.log.e(Self.logTag, string)
    }
}
