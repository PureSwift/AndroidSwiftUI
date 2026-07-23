//
//  Stacks.swift
//  AndroidSwiftUICore
//

public enum HorizontalAlignment: String, Sendable {
    case leading, center, trailing
}

public enum VerticalAlignment: String, Sendable {
    case top, center, bottom
}

public struct Alignment: Sendable {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment
    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    public static let center = Alignment(horizontal: .center, vertical: .center)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)
    public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
    public static let top = Alignment(horizontal: .center, vertical: .top)
    public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
    public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
    public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
    public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}

/// A vertically stacked layout.
public struct VStack<Content: View>: View {

    internal let alignment: HorizontalAlignment
    internal let spacing: Double?
    internal let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension VStack: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = ["alignment": .string(alignment.rawValue)]
        if let spacing { props["spacing"] = .double(spacing) }
        return RenderNode(
            type: "VStack",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

/// A horizontally stacked layout.
public struct HStack<Content: View>: View {

    internal let alignment: VerticalAlignment
    internal let spacing: Double?
    internal let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension HStack: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = ["alignment": .string(alignment.rawValue)]
        if let spacing { props["spacing"] = .double(spacing) }
        return RenderNode(
            type: "HStack",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

/// A depth-stacked (overlaid) layout.
public struct ZStack<Content: View>: View {

    internal let alignment: Alignment
    internal let content: Content

    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    public typealias Body = Never
}

extension ZStack: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "ZStack",
            id: context.path,
            props: [
                "horizontal": .string(alignment.horizontal.rawValue),
                "vertical": .string(alignment.vertical.rawValue),
            ],
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}
