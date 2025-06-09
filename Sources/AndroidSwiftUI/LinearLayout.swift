//
//  HStack.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

/// Android Linear Layout
public struct AndroidLinearLayout <Content> where Content : View {
    
    let orientation: Orientation
    
    let gravity: ViewGravity
    
    let content: Content
    
    public init(
        orientation: LinearLayout.Orientation,
        gravity: ViewGravity,
        @ViewBuilder content: () -> Content
    ) {
        self.orientation = orientation
        self.gravity = gravity
        self.content = content()
    }
}

public extension AndroidLinearLayout {
    
    /// Orientation
    typealias Orientation = AndroidWidget.LinearLayout.Orientation
}

extension AndroidLinearLayout: ParentView {

    public var children: [AnyView] {
        (content as? GroupView)?.children ?? [AnyView(content)]
    }
}

extension AndroidLinearLayout: AndroidViewRepresentable {
    
    public typealias Coordinator = Void
    
    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context.androidContext)
        updateView(view)
        return view
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: AndroidWidget.LinearLayout, context: Self.Context) {
        updateView(view)
    }
}

extension AndroidLinearLayout {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.LinearLayout {
        let view = AndroidWidget.LinearLayout(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.LinearLayout) {
        view.orientation = self.orientation
        view.gravity = self.gravity
    }
}

extension VStack: AndroidPrimitive {
    
    var renderedBody: AnyView {
        let proxy = _VStackProxy(self)
        let gravity = proxy.subject._alignment.vertical.gravity
        let linearLayout = AndroidLinearLayout(orientation: .vertical, gravity: gravity) {
            proxy.subject.content
        }
        return AnyView(linearLayout)
    }
}

extension HStack: AndroidPrimitive {
    
    var renderedBody: AnyView {
        let proxy = _HStackProxy(self)
        let gravity = proxy.subject._alignment.vertical.gravity
        let linearLayout = AndroidLinearLayout(orientation: .horizontal, gravity: gravity) {
            proxy.subject.content
        }
        return AnyView(linearLayout)
    }
}
