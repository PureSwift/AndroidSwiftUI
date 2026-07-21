//
//  Runnable.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

/// Java `Runnable` backed by a Swift closure.
@JavaClass("com.pureswift.swiftandroid.Runnable")
open class Runnable: JavaObject {

    public typealias Block = () -> ()

    @JavaMethod
    @_nonoverride public convenience init(block: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getBlock() -> SwiftObject?
}

@JavaImplementation("com.pureswift.swiftandroid.Runnable")
extension Runnable {

    @JavaMethod
    public func run() {
        guard let block = getBlock()?.valueObject().value as? Block else {
            assertionFailure("Missing block")
            return
        }
        block()
    }
}

public extension Runnable {

    convenience init(_ block: @escaping Block, environment: JNIEnvironment? = nil) {
        let object = SwiftObject(block, environment: environment)
        self.init(block: object, environment: environment)
    }
}
