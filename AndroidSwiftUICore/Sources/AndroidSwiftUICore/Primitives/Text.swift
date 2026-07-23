//
//  Text.swift
//  AndroidSwiftUICore
//

/// A view that displays a string.
public struct Text: View {

    internal let content: String

    public init(_ content: String) {
        self.content = content
    }

    public init<S: StringProtocol>(_ content: S) {
        self.content = String(content)
    }

    public init(verbatim content: String) {
        self.content = content
    }

    public typealias Body = Never
}

extension Text: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(type: "Text", id: context.path, props: ["text": .string(content)])
    }
}
