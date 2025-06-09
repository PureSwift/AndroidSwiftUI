//
//  AndroidTarget.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import JavaKit
import AndroidKit

final class AndroidTarget: Target {
    
    enum Storage {
        case application
        case view(AndroidView.View)
    }
    
    let storage: Storage
    
    var view: AnyView
    
    private init<V: View>(_ view: V, _ storage: Storage) {
        self.view = AnyView(view)
        self.storage = storage
    }
    
    init<V: View>(_ view: V, _ object: AndroidView.View) {
        self.storage = .view(object)
        self.view = AnyView(view)
    }
    
    static var application: AndroidTarget {
        .init(EmptyView(), .application)
    }
}


extension AndroidTarget {
    
    var javaObject: JavaObject {
        switch storage {
        case .application:
            return Application.shared
        case let .view(view):
            return view
        }
    }
    
    func destroy() {
        switch storage {
        case .application:
            break
        case let .view(view):
            break // TODO: Remove from parent
        }
    }
}
