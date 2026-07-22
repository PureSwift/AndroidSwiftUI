//
//  AndroidPaddingModifier.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import Foundation
import AndroidKit

extension _PaddingLayout: AndroidViewModifier {

    /// SwiftUI's default system padding when no explicit length is given.
    private static var defaultInset: CGFloat { 16 }

    public func modifyAndroidView(_ view: AndroidView.View) {
        let density = view.getContext().getResources().getDisplayMetrics().density
        func px(_ points: CGFloat) -> Int32 {
            Int32((Float(points) * density).rounded())
        }
        let resolved = insets ?? EdgeInsets(_all: Self.defaultInset)
        view.setPadding(
            edges.contains(.leading) ? px(resolved.leading) : 0,
            edges.contains(.top) ? px(resolved.top) : 0,
            edges.contains(.trailing) ? px(resolved.trailing) : 0,
            edges.contains(.bottom) ? px(resolved.bottom) : 0
        )
    }
}
