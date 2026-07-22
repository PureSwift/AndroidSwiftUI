//
//  OnCheckedChangeListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

@JavaClass("com.pureswift.swiftandroid.CompoundButtonOnCheckedChangeListener", extends: AndroidWidget.CompoundButton.OnCheckedChangeListener.self)
open class CompoundButtonOnCheckedChangeListener: JavaObject {

    public typealias Action = (Bool) -> ()

    @JavaMethod
    @_nonoverride public convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getAction() -> SwiftObject?
}

@JavaImplementation("com.pureswift.swiftandroid.CompoundButtonOnCheckedChangeListener")
extension CompoundButtonOnCheckedChangeListener {

    @JavaMethod
    func onCheckedChanged(_ isChecked: Bool) {
        // drain queue, matching `ViewOnClickListener`
        RunLoop.main.run(until: Date() + 0.01)
        action(isChecked)
        RunLoop.main.run(until: Date() + 0.01)
    }
}

public extension CompoundButtonOnCheckedChangeListener {

    convenience init(action: @escaping (Bool) -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }

    var action: ((Bool) -> ()) {
        getAction()!.valueObject().value as! Action
    }
}
