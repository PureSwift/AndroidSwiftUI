//
//  VerticalAlignment.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension VerticalAlignment {
    
    var gravity: ViewGravity {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .center:
            return .center
        default:
            return .noGravity
        }
    }
}
