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
        
        // drain main queue
        //drainMainQueue()
    }
}

private extension MainActivity {
    
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
            }
        }
    }
}

extension MainActivity {
    
    static var logTag: String { "MainActivity" }
    
    func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.v(Self.logTag, string)
    }
}
