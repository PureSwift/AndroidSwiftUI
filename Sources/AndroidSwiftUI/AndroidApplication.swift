//
//  AndroidApplication.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit
import OpenCombineShim

@JavaClass("com.pureswift.swiftandroid.Application")
open class Application: AndroidApp.Application {
    
    public internal(set) static var shared: Application!
}

@JavaImplementation("com.pureswift.swiftandroid.Application")
extension Application {
    
    @JavaMethod
    func onCreateSwift() {
        print("\(#function)")
        Application.shared = self
    }
    
    @JavaMethod
    func onTerminateSwift() {
        print("\(#function)")
        Application.shared = nil
    }
}

extension Application {
    
    static var logTag: String { "Application" }
    
    func print(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.v(Self.logTag, string)
    }
}

public extension App {
    
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
      // create renderer
      let renderer = AndroidRenderer(app: app, configuration: configuration)
      AndroidRenderer.shared = renderer
  }
  
  static func _setTitle(_ title: String) {
      
  }

  var _phasePublisher: AnyPublisher<ScenePhase, Never> {
    CurrentValueSubject(.active).eraseToAnyPublisher()
  }

  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
      // TODO: Get dark mode on Android
    CurrentValueSubject(.light).eraseToAnyPublisher()
  }
}
