import Foundation
import AndroidKit

// The umbrella re-exports the whole surface app code needs: the platform-
// neutral SwiftUI API (SwiftUICore) and the Compose/JNI bridge (ComposeUI).
// This module itself adds only the Android host — android.view bridging.
@_exported import SwiftUICore
@_exported import ComposeUI

/// Logs a message to logcat under the "SwiftUI" tag, so app code doesn't need
/// AndroidKit (whose `AndroidView.View` would collide with the core's `View`).
public func AndroidSwiftUILog(_ message: String) {
    let log = try! JavaClass<AndroidUtil.Log>()
    _ = log.v("SwiftUI", message)
}
