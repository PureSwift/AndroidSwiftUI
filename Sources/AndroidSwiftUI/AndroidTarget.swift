//
//  AndroidTarget.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

final class AndroidTarget: Target {
    
    enum Storage {
        case application // main activity
        case view(AndroidView.View)
        case fragment(AndroidApp.Fragment, container: AndroidView.View)
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
    
    init<V: View>(_ view: V, _ object: AndroidApp.Fragment, container: AndroidView.View) {
        self.storage = .fragment(object, container: container)
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
            view.getParent()?.as(ViewGroup.self)?.removeView(view)
        case let .fragment(fragment, container):
            if let transaction = fragment.getFragmentManager()?.beginTransaction() {
                _ = transaction.remove(fragment)
                _ = transaction.commitAllowingStateLoss()
            }
            container.getParent()?.as(ViewGroup.self)?.removeView(container)
        }
    }
}
