//
//  Gradient.swift
//  AndroidSwiftUICore
//

/// A location in a view, normalized to its size (0…1 on each axis).
public struct UnitPoint: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) { self.x = x; self.y = y }

    public static let leading = UnitPoint(x: 0, y: 0.5)
    public static let trailing = UnitPoint(x: 1, y: 0.5)
    public static let top = UnitPoint(x: 0.5, y: 0)
    public static let bottom = UnitPoint(x: 0.5, y: 1)
    public static let topLeading = UnitPoint(x: 0, y: 0)
    public static let topTrailing = UnitPoint(x: 1, y: 0)
    public static let bottomLeading = UnitPoint(x: 0, y: 1)
    public static let bottomTrailing = UnitPoint(x: 1, y: 1)
    public static let center = UnitPoint(x: 0.5, y: 0.5)
}

/// An ordered list of colors for a gradient.
public struct Gradient: Equatable, Sendable {
    public var colors: [Color]
    public init(colors: [Color]) { self.colors = colors }
}

/// A linear gradient fill, usable as a view.
public struct LinearGradient: View {

    internal let colors: [Color]
    internal let startPoint: UnitPoint
    internal let endPoint: UnitPoint

    public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.init(colors: gradient.colors, startPoint: startPoint, endPoint: endPoint)
    }

    public typealias Body = Never
}

extension LinearGradient: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(type: "LinearGradient", id: context.path, props: [
            "colors": .array(colors.map { $0.propValue }),
            "startX": .double(startPoint.x), "startY": .double(startPoint.y),
            "endX": .double(endPoint.x), "endY": .double(endPoint.y),
        ])
    }
}
