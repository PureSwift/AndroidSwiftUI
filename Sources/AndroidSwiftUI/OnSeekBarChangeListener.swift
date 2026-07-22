//
//  OnSeekBarChangeListener.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

/// Bridges `SeekBar.OnSeekBarChangeListener` to Swift.
///
/// The Kotlin side collapses the three callbacks into one and drops the `SeekBar` argument,
/// so the native signature matches this declaration exactly — passing the bar through would
/// shift the remaining arguments and yield garbage values.
@JavaClass("com.pureswift.swiftandroid.SeekBarOnSeekBarChangeListener")
open class SeekBarOnSeekBarChangeListener: JavaObject {

    /// Reports the progress and whether the change came from the user.
    public typealias Action = (Int32) -> ()

    @JavaMethod
    @_nonoverride public convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    public func getAction() -> SwiftObject?

    /// Registers this listener on the bar, since the listener type itself has no binding.
    @JavaMethod
    public func attach(_ seekBar: AndroidWidget.SeekBar?)
}

@JavaImplementation("com.pureswift.swiftandroid.SeekBarOnSeekBarChangeListener")
extension SeekBarOnSeekBarChangeListener {

    @JavaMethod
    func onProgressChangedSwift(_ progress: Int32, _ fromUser: Bool) {
        // ignore programmatic changes, which the renderer makes while updating the view
        guard fromUser else { return }
        // drain queue, matching `ViewOnClickListener`
        RunLoop.main.run(until: Date() + 0.01)
        action(progress)
        RunLoop.main.run(until: Date() + 0.01)
    }
}

public extension SeekBarOnSeekBarChangeListener {

    convenience init(action: @escaping (Int32) -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }

    var action: ((Int32) -> ()) {
        getAction()!.valueObject().value as! Action
    }
}
