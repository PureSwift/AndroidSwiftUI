//
//  Form.swift
//  AndroidSwiftUICore
//
//  A Form is a grouped, scrolling container of Sections; a Section groups rows
//  under an optional header and footer. The interpreter renders sections as
//  inset, rounded groups with dividers between rows.
//

public struct Form<Content: View>: View {
    internal let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public typealias Body = Never
}

extension Form: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "Form",
            id: context.path,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

public struct Section<Content: View>: View {

    internal let header: String?
    internal let footer: String?
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.header = nil
        self.footer = nil
        self.content = content()
    }

    public init<S: StringProtocol>(_ header: S, @ViewBuilder content: () -> Content) {
        self.header = String(header)
        self.footer = nil
        self.content = content()
    }

    public init<H: StringProtocol, F: StringProtocol>(header: H, footer: F, @ViewBuilder content: () -> Content) {
        self.header = String(header)
        self.footer = String(footer)
        self.content = content()
    }

    public typealias Body = Never
}

extension Section: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = [:]
        if let header { props["header"] = .string(header) }
        if let footer { props["footer"] = .string(footer) }
        return RenderNode(
            type: "Section",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}
