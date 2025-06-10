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
/*
@JavaClass("com.pureswift.swiftandroid.Runnable", extends: AndroidJavaLang.Runnable.self)
open class Runnable: JavaObject {
    
    public typealias Block = () -> ()
    
    @JavaMethod
    @_nonoverride public convenience init(block: SwiftObject?, environment: JNIEnvironment? = nil)
    
    public convenience init(_ block: @escaping () -> Void, environment: JNIEnvironment? = nil) {
        let object = SwiftObject(block, environment: environment)
        self.init(block: object, environment: environment)
    }
}

@JavaImplementation("com.pureswift.swiftandroid.Runnable")
extension Runnable {
    
    @JavaMethod
    func run() {
        block()
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
*/
