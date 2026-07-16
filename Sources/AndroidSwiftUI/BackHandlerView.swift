//
//  BackHandlerView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

/// Hosts a Jetpack Compose `BackHandler` to intercept the system back button.
@JavaClass("com.pureswift.swiftandroid.BackHandlerView")
open class BackHandlerView: AndroidView.View {

    @JavaMethod
    @_nonoverride public convenience init(_ context: AndroidContent.Context?, _ callback: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getCallback() -> SwiftObject?

    @JavaMethod
    open func setBackHandlerEnabled(_ enabled: Bool)
}

@JavaImplementation("com.pureswift.swiftandroid.BackHandlerView")
extension BackHandlerView {

    @JavaMethod
    func onBack() {
        callback()
    }
}

public extension BackHandlerView {

    convenience init(_ context: AndroidContent.Context, environment: JNIEnvironment? = nil, action: @escaping () -> ()) {
        let object = SwiftObject(action, environment: environment)
        self.init(context, object, environment: environment)
    }

    var callback: (() -> ()) {
        getCallback()!.valueObject().value as! (() -> ())
    }
}
