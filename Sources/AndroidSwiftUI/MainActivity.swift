//
//  Activity.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import Foundation
import AndroidKit
import JavaLang

@JavaClass("com.pureswift.swiftandroid.MainActivity")
open class MainActivity: AndroidApp.Activity {
    
    public internal(set) static var shared: MainActivity!
    
    @JavaMethod
    open func setRootView(_ view: AndroidView.View?)
}

@JavaImplementation("com.pureswift.swiftandroid.MainActivity")
extension MainActivity {
    
    @JavaMethod
    public func onCreateSwift(_ savedInstanceState: BaseBundle?) {
        log("\(self).\(#function)")
        MainActivity.shared = self

        // Point @AppStorage at a file in the app's private storage before any
        // view is built, so the first evaluation already reads saved values.
        // The path comes through the existing Context binding — no new bridge.
        if let directory = (self as AndroidContent.Context).getFilesDir()?.getAbsolutePath() {
            AppStorageStore.backend = FileAppStorage(directory: directory)
        } else {
            log("MainActivity: no files directory; @AppStorage stays in memory")
        }

        // start app
        AndroidSwiftUIMain()

        runAsync()
    }

    @JavaMethod
    public func onActivityResultSwift(_ requestCode: Int32, _ resultCode: Int32, _ data: AndroidContent.Intent?) {
        log("\(self).\(#function) requestCode \(requestCode) resultCode \(resultCode)")
    }
}

private extension MainActivity {
    
    func runAsync() {
        RunLoop.main.run(until: Date() + 0.1)
        DispatchQueue.main.async {
            Self.log("\(self).\(#function) Main Thread Async")
        }
        DispatchQueue.global(qos: .default).async {
            Self.log("\(self).\(#function) Default Dispatch Queue Async")
        }
        Task {
            Self.log("\(self).\(#function) Task Started")
            await MainActor.run {
                RunLoop.main.run(until: Date() + 0.1)
            }
        }
    }
}

extension MainActivity {
    
    static var logTag: String { "MainActivity" }
    
    static let log = try! JavaClass<AndroidUtil.Log>()
    
    static func log(_ string: String) {
        _ = Self.log.d(Self.logTag, string)
    }
    
    static func logInfo(_ string: String) {
        _ = Self.log.i(Self.logTag, string)
    }
    
    static func logError(_ string: String) {
        _ = Self.log.e(Self.logTag, string)
    }
    
    func log(_ string: String) {
        Self.log(string)
    }
    
    func logError(_ string: String) {
        Self.logError(string)
    }
}
