//
//  AsyncImage.swift
//  SwiftUICore
//
//  A remote image. The interpreter fetches and decodes off the main thread,
//  showing a progress indicator while loading and a placeholder on failure —
//  the whole lifecycle stays Compose-side, so loading never touches the bridge.
//

import Foundation

public struct AsyncImage: View {

    internal let url: URL?

    public init(url: URL?) {
        self.url = url
    }

    public typealias Body = Never
}

extension AsyncImage: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = [:]
        if let url { props["url"] = .string(url.absoluteString) }
        return RenderNode(type: "AsyncImage", id: context.path, props: props)
    }
}

// MARK: - Content mode

/// How a resizable image maps into the space offered it.
public enum ContentMode: String, Sendable {
    case fit, fill
}

public struct _ContentModeModifier: RenderModifier {
    let mode: ContentMode
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "contentMode", args: ["mode": .string(mode.rawValue)])
    }
}

public extension View {

    func scaledToFit() -> ModifiedContent<Self, _ContentModeModifier> {
        modifier(_ContentModeModifier(mode: .fit))
    }

    func scaledToFill() -> ModifiedContent<Self, _ContentModeModifier> {
        modifier(_ContentModeModifier(mode: .fill))
    }

    func aspectRatio(contentMode: ContentMode) -> ModifiedContent<Self, _ContentModeModifier> {
        modifier(_ContentModeModifier(mode: contentMode))
    }
}
