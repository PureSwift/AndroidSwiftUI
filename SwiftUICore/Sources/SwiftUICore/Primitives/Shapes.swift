//
//  Shapes.swift
//  SwiftUICore
//
//  Shape views fill their frame with a fill color. A shape without an explicit
//  `.frame` renders at zero size (the layout engine's fill-the-parent behavior
//  is not modeled); the catalog always frames them.
//

private func shapeNode(_ kind: String, fill: Color?, cornerRadius: Double? = nil, context: ResolveContext) -> RenderNode {
    var props: [String: PropValue] = ["shape": .string(kind)]
    if let fill { props["fill"] = fill.propValue }
    if let cornerRadius { props["cornerRadius"] = .double(cornerRadius) }
    return RenderNode(type: "Shape", id: context.path, props: props)
}

public struct Rectangle: View {
    internal var fillColor: Color?
    public init() {}
    public func fill(_ color: Color) -> Rectangle { var copy = self; copy.fillColor = color; return copy }
    public typealias Body = Never
}

extension Rectangle: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        shapeNode("rectangle", fill: fillColor, context: context)
    }
}

public struct Circle: View {
    internal var fillColor: Color?
    public init() {}
    public func fill(_ color: Color) -> Circle { var copy = self; copy.fillColor = color; return copy }
    public typealias Body = Never
}

extension Circle: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        shapeNode("circle", fill: fillColor, context: context)
    }
}

public struct Capsule: View {
    internal var fillColor: Color?
    public init() {}
    public func fill(_ color: Color) -> Capsule { var copy = self; copy.fillColor = color; return copy }
    public typealias Body = Never
}

extension Capsule: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        shapeNode("capsule", fill: fillColor, context: context)
    }
}

public struct RoundedRectangle: View {
    internal let cornerRadius: Double
    internal var fillColor: Color?
    public init(cornerRadius: Double) { self.cornerRadius = cornerRadius }
    public func fill(_ color: Color) -> RoundedRectangle { var copy = self; copy.fillColor = color; return copy }
    public typealias Body = Never
}

extension RoundedRectangle: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        shapeNode("roundedRectangle", fill: fillColor, cornerRadius: cornerRadius, context: context)
    }
}
