//
//  Link.swift
//  AndroidSwiftUICore
//
//  Opens a URL outside the app. Nothing crosses back into Swift: the
//  interpreter hands the address to Compose's UriHandler, so the platform
//  decides which app answers it and no callback or bridge entry is involved.
//

import Foundation

public struct Link<Label: View>: View {

    internal let destination: URL
    internal let label: Label

    public init(destination: URL, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    public typealias Body = Never
}

public extension Link where Label == Text {
    init<S: StringProtocol>(_ title: S, destination: URL) {
        self.init(destination: destination) { Text(title) }
    }
}

extension Link: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "Link",
            id: context.path,
            props: ["url": .string(destination.absoluteString)],
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}
