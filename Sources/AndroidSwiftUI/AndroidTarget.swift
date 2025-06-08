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
        case application(AndroidSwiftUI.Application)
        case view(AndroidView.View)
    }
    
    let storage: Storage
    
    var view: AnyView
    
    init<V: View>(_ view: V, _ object: AndroidView.View) {
        self.storage = .view(object)
        self.view = AnyView(view)
    }
    
    init(_ app: AndroidSwiftUI.Application) {
        self.storage = .application(app)
        self.view = AnyView(EmptyView())
    }
}


extension AndroidTarget {
    
    var javaObject: JavaObject {
        switch storage {
        case let .application(application):
            return application
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
