//
//  Activity.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import Foundation
import AndroidKit
import AndroidJavaLang

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
        
        // start app
        AndroidSwiftUIMain()
        
        runAsync()
        
        // drain main queue
        //drainMainQueue()
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
    
    nonisolated func drainMainQueue() {
        log("\(self).\(#function)")
        // drain main queue
        Task { [weak self] in
            while let self = self {
                log("\(self).\(#function) Task Started")
                if #available(macOS 13.0, *) {
                    try? await Task.sleep(for: .milliseconds(100))
                }
                let runnable = AndroidSwiftUI.Runnable {
                    RunLoop.main.run(until: Date() + 0.01)
                }
                self.runOnUiThread(runnable.as(AndroidJavaLang.Runnable.self))
                if #available(macOS 13.0, *) {
                    try? await Task.sleep(for: .seconds(1))
                }
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
