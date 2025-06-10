//
//  JNIObject.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/10/25.
//

import JavaKit
import JavaRuntime
import JavaTypes

internal protocol JNIObject: AnyObject { }

extension JNIObject {
    
    static fileprivate func recoverPointer( _ swiftObject: jlong) -> uintptr_t {
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
    
    internal func swiftValue() -> jvalue {
        return jvalue( j: jlong(bitPattern: unsafeBitCast(Unmanaged.passRetained(self), to: uintptr_t.self)))
    }
    
    internal static func swiftObject(from pointer: jlong) -> Self {
        return unsafeBitCast( recoverPointer( pointer ), to: Self.self )
    }
    
    internal static func release(swiftObject: jlong) {
        
        let toRelease = unsafeBitCast( recoverPointer( swiftObject ), to: Self.self )
        
        Unmanaged.passUnretained(toRelease).release()
    }
}

extension jlong: @retroactive JavaValue {
    
  public typealias JNIType = jlong

  public static var jvalueKeyPath: WritableKeyPath<jvalue, JNIType> { \.j }

  public func getJNIValue(in environment: JNIEnvironment) -> JNIType { self }

  public init(fromJNI value: JNIType, in environment: JNIEnvironment) {
    self = value
  }

  public static var javaType: JavaType { .long }

  public static func jniMethodCall(
    in environment: JNIEnvironment
  ) -> ((JNIEnvironment, jobject, jmethodID, UnsafePointer<jvalue>?) -> JNIType) {
    environment.interface.CallLongMethodA
  }

  public static func jniFieldGet(in environment: JNIEnvironment) -> JNIFieldGet<JNIType> {
    environment.interface.GetLongField
  }

  public static func jniFieldSet(in environment: JNIEnvironment) -> JNIFieldSet<JNIType> {
    environment.interface.SetLongField
  }

  public static func jniStaticMethodCall(
    in environment: JNIEnvironment
  ) -> ((JNIEnvironment, jobject, jmethodID, UnsafePointer<jvalue>?) -> JNIType) {
    environment.interface.CallStaticLongMethodA
  }

  public static func jniStaticFieldGet(in environment: JNIEnvironment) -> JNIStaticFieldGet<JNIType> {
    environment.interface.GetStaticLongField
  }

  public static func jniStaticFieldSet(in environment: JNIEnvironment) -> JNIStaticFieldSet<JNIType> {
    environment.interface.SetStaticLongField
  }

  public static func jniNewArray(in environment: JNIEnvironment) -> JNINewArray {
    environment.interface.NewLongArray
  }

  public static func jniGetArrayRegion(in environment: JNIEnvironment) -> JNIGetArrayRegion<JNIType> {
    environment.interface.GetLongArrayRegion
  }

  public static func jniSetArrayRegion(in environment: JNIEnvironment) -> JNISetArrayRegion<JNIType> {
    environment.interface.SetLongArrayRegion
  }

  public static var jniPlaceholderValue: jlong {
    0
  }
}

extension UnsafeMutablePointer<JNIEnv?> {
  var interface: JNINativeInterface_ { self.pointee!.pointee }
}
