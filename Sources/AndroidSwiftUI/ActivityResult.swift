//
//  ActivityResult.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

/// The result of an activity started for a result.
public struct ActivityResult {

    /// `Activity.RESULT_OK`
    public static var ok: Int32 { -1 }

    /// `Activity.RESULT_CANCELED`
    public static var canceled: Int32 { 0 }

    /// The result code returned by the finished activity.
    public let resultCode: Int32

    /// The intent carrying result data, if any.
    public let data: AndroidContent.Intent?

    /// Whether the activity finished with `Activity.RESULT_OK`.
    public var isSuccess: Bool {
        resultCode == Self.ok
    }
}

/// Dispatches `onActivityResult` callbacks to the representable that started the activity,
/// keyed by request code.
internal enum ActivityResultRegistry {

    typealias Handler = (ActivityResult) -> ()

    private static var handlers = [Int32: Handler]()

    private static var requestCodes = [RepresentableCoordinatorStorage.Key: Int32]()

    // request codes must fit in the lower 16 bits
    private static var nextRequestCode: Int32 = 0x1000

    /// Registers a handler and associates it with the mounted Java object for cleanup.
    static func register(for object: JavaObject, _ handler: @escaping Handler) -> Int32 {
        let requestCode = nextRequestCode
        nextRequestCode = requestCode >= 0xFFFF ? 0x1000 : requestCode + 1
        handlers[requestCode] = handler
        requestCodes[.init(object)] = requestCode
        return requestCode
    }

    /// Removes the handler registered for the specified mounted Java object.
    static func unregister(for object: JavaObject) {
        guard let requestCode = requestCodes.removeValue(forKey: .init(object)) else {
            return
        }
        handlers[requestCode] = nil
    }

    /// Delivers a result to the registered handler.
    @discardableResult
    static func dispatch(requestCode: Int32, result: ActivityResult) -> Bool {
        guard let handler = handlers[requestCode] else {
            return false
        }
        handler(result)
        return true
    }
}
