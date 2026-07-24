//
//  AndroidApplication.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit
#if canImport(AndroidLooper)
import AndroidLooper
#endif

@JavaClass("com.pureswift.swiftandroid.Application")
open class Application: AndroidApp.Application {
    
    public internal(set) static var shared: Application!
}

@JavaImplementation("com.pureswift.swiftandroid.Application")
extension Application {
    
    @JavaMethod
    func onCreateSwift() {
        log("\(self).\(#function)")
        Application.shared = self

        // Bind the Android main looper to `AndroidMainActor` at process launch.
        // `Application.onCreate` runs on the main thread — the required call site
        // — so `@MainActor` and `DispatchQueue.main` dispatch correctly from here
        // on, without hand-draining `RunLoop.main`.
        #if canImport(AndroidLooper)
        let boundMainLooper = AndroidMainActor.setupMainLooper()
        log("AndroidMainActor.setupMainLooper() -> \(boundMainLooper)")
        #endif
    }
    
    @JavaMethod
    func onTerminateSwift() {
        log("\(self).\(#function)")
        Application.shared = nil
    }
}

extension Application {
    
    static var logTag: String { "Application" }
    
    func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.v(Self.logTag, string)
    }
}

/// The app's entry point, defined by the application module.
@_silgen_name("AndroidSwiftUIMain")
func AndroidSwiftUIMain()
