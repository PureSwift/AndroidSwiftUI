//
//  OnItemSelectedListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

/// Bridges `AdapterView.OnItemSelectedListener` to Swift.
///
/// As with the other listener bridges, the Kotlin side forwards only the position: the
/// native symbol is derived from this declaration, so passing the adapter view and item id
/// through would shift the arguments.
@JavaClass("com.pureswift.swiftandroid.SpinnerOnItemSelectedListener")
open class SpinnerOnItemSelectedListener: JavaObject {

    public typealias Action = (Int32) -> ()

    @JavaMethod
    @_nonoverride public convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getAction() -> SwiftObject?

    /// Registers this listener on the spinner, since the listener type itself has no binding.
    @JavaMethod
    public func attach(_ spinner: AndroidWidget.Spinner?)
}

@JavaImplementation("com.pureswift.swiftandroid.SpinnerOnItemSelectedListener")
extension SpinnerOnItemSelectedListener {

    @JavaMethod
    func onItemSelectedSwift(_ position: Int32) {
        // drain queue, matching `ViewOnClickListener`
        RunLoop.main.run(until: Date() + 0.01)
        action(position)
        RunLoop.main.run(until: Date() + 0.01)
    }
}

public extension SpinnerOnItemSelectedListener {

    convenience init(action: @escaping (Int32) -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }

    var action: ((Int32) -> ()) {
        getAction()!.valueObject().value as! Action
    }
}
