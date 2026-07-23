import Foundation
import AndroidKit

// The public SwiftUI API surface comes from the platform-neutral core.
@_exported import AndroidSwiftUICore

/// Logs a message to logcat under the "SwiftUI" tag, so app code doesn't need
/// AndroidKit (whose `AndroidView.View` would collide with the core's `View`).
public func AndroidSwiftUILog(_ message: String) {
    let log = try! JavaClass<AndroidUtil.Log>()
    _ = log.v("SwiftUI", message)
}
