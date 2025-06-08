//
//  AndroidView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

internal protocol AnyAndroidView {
    
    func build(parent: JavaObject, before sibling: JavaObject?) -> JavaObject?
    
    func update(component: inout JavaObject, parent: JavaObject)
    
    func remove(component: JavaObject, parent: JavaObject)
}

internal struct _AndroidView <Content: View> : View, AnyAndroidView {
    
    let _build: (JavaObject, JavaObject?) -> JavaObject?
    
    let _update: (inout JavaObject, JavaObject) -> ()
    
    let _remove: (JavaObject, JavaObject) -> ()
    
    let content: Content
    
    init(
        build: @escaping (JavaObject, JavaObject?) -> JavaObject?,
        update: @escaping (inout JavaObject, JavaObject) -> (),
        remove: @escaping (JavaObject, JavaObject) -> (),
        @ViewBuilder content: () -> Content
    ) {
        self._build = build
        self._update = update
        self._remove = remove
        self.content = content()
    }
    
    func build(parent: JavaObject, before sibling: JavaObject?) -> JavaObject? {
        _build(parent, sibling)
    }
    
    func update(component: inout JavaObject, parent: JavaObject) {
        _update(&component, parent)
    }
    
    func remove(component: JavaObject, parent: JavaObject) {
        _remove(component, parent)
    }
    
    var body: Never {
        neverBody("ComponentView")
    }
}

extension _AndroidView: ParentView {
    
    var children: [AnyView] {
        [AnyView(content)]
    }
}
