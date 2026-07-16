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
        case application // main activity
        case view(AndroidView.View)
        case fragment(AndroidApp.Fragment)
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
    
    init<V: View>(_ view: V, _ object: AndroidApp.Fragment) {
        self.storage = .fragment(object)
        self.view = AnyView(view)
    }
    
    static var application: AndroidTarget {
        .init(EmptyView(), .application)
    }
}

extension AndroidTarget {
    
    func destroy() {
        switch storage {
        case .application:
            break
        case let .view(view):
            break // TODO: Remove from parent
        case let .fragment(fragment):
            break // TODO:
        }
    }
}
