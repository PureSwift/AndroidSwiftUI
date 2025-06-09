//
//  HorizontalAlignment.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension HorizontalAlignment {
    
    var gravity: ViewGravity {
        switch self {
        case .center:
            return .center
        case .leading:
            return .left
        case .trailing:
            return .right
        default:
            return .noGravity
        }
    }
}
