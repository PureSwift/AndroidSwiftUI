//
//  SceneContainerView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import AndroidKit

struct SceneContainerView<Content: View>: View, AnyAndroidView {
     
  let content: Content

  var body: Never {
    neverBody("SceneContainerView")
  }
    
    func build(parent: JavaObject, before sibling: JavaObject?) -> JavaObject? {
        return nil
    }
    
    func update(component: inout JavaObject, parent: JavaObject) {
        
    }
    
    func remove(component: JavaObject, parent: JavaObject) {
        
    }
}
