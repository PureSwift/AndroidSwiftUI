//
//  JavaRetainedValue.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import JavaKit
import JavaRuntime

@JavaClass("com.pureswift.swiftandroid.SwiftObject")
open class SwiftObject: JavaObject {
    
    @JavaMethod
    @_nonoverride public convenience init(swiftObject: jlong, type: String, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    open func getSwiftObject() -> jlong
    
    @JavaMethod
    open func getType() -> String
}

@JavaImplementation("com.pureswift.swiftandroid.SwiftObject")
extension SwiftObject {
    
    @JavaMethod
    public func toStringSwift() -> String {
        "\(valueObject().value)"
    }
    
    @JavaMethod
    public func finalizeSwift() {
        // release owned swift value
        releaseValueObject()
    }
}

extension SwiftObject {
    
    convenience init<T>(_ value: T, environment: JNIEnvironment? = nil) {
        let box = JavaRetainedValue(value)
        let pointer = box.swiftValue().j
        let type = box.type
        self.init(swiftObject: pointer, type: type, environment: environment)
    }
    
    func valueObject() -> JavaRetainedValue {
        JavaRetainedValue.swiftObject(from: getSwiftObject())
    }
}

private extension SwiftObject {
    
    func releaseValueObject() {
        let pointer = getSwiftObject()
        JavaRetainedValue.release(swiftObject: pointer)
    }
}

/// Swift Object retained by JVM.
final class JavaRetainedValue {
    
    var value: Any
    
    var type: String {
        String(describing: Swift.type(of: value))
    }
    
    init<T>(_ value: T) {
        self.value = value
    }
}

extension JavaRetainedValue: JNIObject { }
