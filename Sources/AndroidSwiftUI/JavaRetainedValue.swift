//
//  JavaRetainedValue.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import JavaKit
import JavaRuntime

@JavaClass("com.pureswift.swiftandroid.SwiftObject")
public class SwiftObject: JavaObject {
    
    @JavaMethod
    @_nonoverride public convenience init(swiftObject: Int64, type: String, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    func getSwiftObject() -> Int64
    
    @JavaMethod
    func getType() -> String
}

@JavaImplementation("com.pureswift.swiftandroid.SwiftObject")
extension SwiftObject {
    
    @JavaMethod
    public func finalizeSwift() {
        // release owned swift value
        release()
    }
}

extension SwiftObject {
    
    convenience init<T>(_ value: T, environment: JNIEnvironment? = nil) {
        let box = JavaRetainedValue(value)
        let pointer = box.javaPointerRetained()
        let type = box.type
        self.init(swiftObject: pointer, type: type, environment: environment)
    }
    /*
    var value: T {
        get {
            valueObject.value
        }
        set {
            valueObject.value = newValue
        }
    }*/
    
    func valueObject<T>(_ type: T.Type) -> JavaRetainedValue<T> {
        JavaRetainedValue<T>.unretained(getSwiftObject())
    }
}

private extension SwiftObject {
    
    func release() {
        let pointer = getSwiftObject()
        JavaRetainedValue<T>.release(pointer)
    }
}

/// Swift Object retained by JVM.
final class JavaRetainedValue <T> {
    
    var value: T
    
    var type: String {
        String(describing: T.self)
    }
    
    init(_ value: T) {
        self.value = value
    }
}

extension JavaRetainedValue {
    
    /// Get the object pointer with the ARC +1 so Java owns it.
    ///
    /// Make sure to only call this once.
    func javaPointerRetained() -> Int64 {
        Int64(unsafeBitCast(Unmanaged.passRetained(self), to: uintptr_t.self))
    }
    
    static func release(_ swiftObject: Int64) {
        let object = unretained(swiftObject)
        Unmanaged.passUnretained(object).release()
    }
    
    static func unretained(_ swiftObject: Int64) -> JavaRetainedValue<T> {
        unsafeBitCast( recoverPointer( swiftObject ), to: JavaRetainedValue<T>.self )
    }
    
    static fileprivate func recoverPointer( _ swiftObject: Int64) -> uintptr_t {
        #if os(Android)
        let swiftPointer = uintptr_t(swiftObject&0xffffffff)
        #else
        let swiftPointer = uintptr_t(swiftObject)
        #endif
        if swiftPointer == 0 {
            assertionFailure()
        }
        return swiftPointer
    }
}
