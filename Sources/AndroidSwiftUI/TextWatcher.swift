//
//  TextWatcher.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

/// Bridges `TextWatcher` to Swift.
///
/// Only the changed text is reported: the Kotlin side collapses the three callbacks into a
/// single one, since the edit offsets aren't needed to drive a `String` binding.
@JavaClass("com.pureswift.swiftandroid.EditTextTextWatcher")
open class EditTextTextWatcher: JavaObject {

    public typealias Action = (String) -> ()

    @JavaMethod
    @_nonoverride public convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getAction() -> SwiftObject?

    /// Registers this watcher on the field, since `TextWatcher` itself has no binding.
    @JavaMethod
    public func attach(_ editText: AndroidWidget.EditText?)
}

@JavaImplementation("com.pureswift.swiftandroid.EditTextTextWatcher")
extension EditTextTextWatcher {

    @JavaMethod
    func onTextChangedSwift(_ text: String) {
        // drain queue, matching `ViewOnClickListener`
        RunLoop.main.run(until: Date() + 0.01)
        action(text)
        RunLoop.main.run(until: Date() + 0.01)
    }
}

public extension EditTextTextWatcher {

    convenience init(action: @escaping (String) -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }

    var action: ((String) -> ()) {
        getAction()!.valueObject().value as! Action
    }
}
