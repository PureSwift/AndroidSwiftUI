//
//  Activity.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

@JavaClass("com.pureswift.swiftandroid.MainActivity")
open class MainActivity: AndroidApp.Activity {
    
    final static var shared: MainActivity!
    
    @JavaMethod
    open func setRootView(_ view: AndroidView.View)
}

@JavaImplementation("com.pureswift.swiftandroid.MainActivity")
extension MainActivity {
    
    @JavaMethod
    public func onCreateSwift(_ savedInstanceState: BaseBundle?) {
        log("\(self).\(#function)")
        MainActivity.shared = self
        
        // start app
        AndroidSwiftUIMain()
    }
}

extension MainActivity {
    
    static var logTag: String { "MainActivity" }
    
    func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.v(Self.logTag, string)
    }
}
