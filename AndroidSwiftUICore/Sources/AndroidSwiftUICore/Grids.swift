//
//  Grids.swift
//  AndroidSwiftUICore
//
//  Grids resolve their cells eagerly (bounded in practice) into a node carrying
//  the track spec; the interpreter lays them out in a Compose lazy grid.
//

/// A grid track description.
public struct GridItem: Sendable {

    public enum Size: Sendable {
        case fixedTrack(Double)
        case flexibleTrack(minimum: Double, maximum: Double)
        case adaptiveTrack(minimum: Double, maximum: Double)
    }

    public var size: Size

    public init(_ size: Size = .flexible()) {
        self.size = size
    }
}

public extension GridItem.Size {
    static func fixed(_ value: Double) -> GridItem.Size { .fixedTrack(value) }
    static func flexible(minimum: Double = 10, maximum: Double = .infinity) -> GridItem.Size {
        .flexibleTrack(minimum: minimum, maximum: maximum)
    }
    static func adaptive(minimum: Double, maximum: Double = .infinity) -> GridItem.Size {
        .adaptiveTrack(minimum: minimum, maximum: maximum)
    }
}

/// A grid growing vertically, laid out across `columns` tracks.
public struct LazyVGrid<Content: View>: View {

    internal let columns: [GridItem]
    internal let spacing: Double?
    internal let content: Content

    public init(columns: [GridItem], spacing: Double? = nil, @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension LazyVGrid: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        gridNode(type: "LazyVGrid", tracks: columns, spacing: spacing, content: content, context: context)
    }
}

/// A grid growing horizontally, laid out down `rows` tracks.
public struct LazyHGrid<Content: View>: View {

    internal let rows: [GridItem]
    internal let spacing: Double?
    internal let content: Content

    public init(rows: [GridItem], spacing: Double? = nil, @ViewBuilder content: () -> Content) {
        self.rows = rows
        self.spacing = spacing
        self.content = content()
    }

    public typealias Body = Never
}

extension LazyHGrid: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        gridNode(type: "LazyHGrid", tracks: rows, spacing: spacing, content: content, context: context)
    }
}

private func gridNode<Content: View>(
    type: String,
    tracks: [GridItem],
    spacing: Double?,
    content: Content,
    context: ResolveContext
) -> RenderNode {
    var props: [String: PropValue] = [:]
    // a single adaptive track fits as many columns as possible; otherwise it's
    // a fixed track count — the common flexible-columns usage
    if tracks.count == 1, case .adaptiveTrack(let minimum, _) = tracks[0].size {
        props["adaptiveMin"] = .double(minimum)
    } else {
        props["trackCount"] = .int(max(tracks.count, 1))
    }
    if let spacing { props["spacing"] = .double(spacing) }
    return RenderNode(
        type: type,
        id: context.path,
        props: props,
        children: Evaluator.resolveChildren(content, context.descending("content"))
    )
}
