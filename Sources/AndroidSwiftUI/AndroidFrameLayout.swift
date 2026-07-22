//
//  AndroidFrameLayout.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

/// Android Frame Layout, which overlays its children on top of one another.
public struct AndroidFrameLayout <Content> where Content : View {

    let gravity: ViewGravity

    let content: Content

    public init(
        gravity: ViewGravity,
        @ViewBuilder content: () -> Content
    ) {
        self.gravity = gravity
        self.content = content()
    }
}

extension AndroidFrameLayout: ParentView {

    public var children: [AnyView] {
        (content as? GroupView)?.children ?? [AnyView(content)]
    }
}

extension AndroidFrameLayout: AndroidViewRepresentable {

    /// The gravity applied to each child, retained so the renderer can read it back off the
    /// mounted `FrameLayout` when assigning that child's layout parameters. `FrameLayout`
    /// positions children through their own parameters rather than a container-wide gravity,
    /// and the renderer only has the parent's native view to work from.
    public typealias Coordinator = ViewGravity

    public func makeCoordinator() -> ViewGravity { gravity }

    public func makeAndroidView(context: Self.Context) -> AndroidWidget.FrameLayout {
        AndroidWidget.FrameLayout(context.androidContext)
    }

    public func updateAndroidView(_ view: AndroidWidget.FrameLayout, context: Self.Context) { }
}

extension ZStack: AndroidPrimitive {

    var renderedBody: AnyView {
        let frameLayout = AndroidFrameLayout(gravity: alignment.gravity) {
            content
        }
        return AnyView(frameLayout)
    }
}

extension Alignment {

    /// The combined horizontal and vertical gravity for positioning a view within a frame.
    ///
    /// Unlike the single-axis alignments used by the linear stacks, both axes are resolved
    /// here, so centering must use the per-axis flags rather than the combined `center`
    /// value, which would otherwise center on both axes regardless of the other component.
    var gravity: ViewGravity {
        var gravity = ViewGravity()
        switch horizontal {
        case .leading:
            gravity.insert(.left)
        case .trailing:
            gravity.insert(.right)
        default:
            gravity.insert(.centerHorizontal)
        }
        switch vertical {
        case .top:
            gravity.insert(.top)
        case .bottom:
            gravity.insert(.bottom)
        default:
            gravity.insert(.centerVertical)
        }
        return gravity
    }
}
