//
//  Views.swift
//  AndroidSwiftUICore
//
//  Primitives added for the first gallery wave.
//

/// A scrollable container.
public struct ScrollView<Content: View>: View {

    internal let axis: Axis
    internal let content: Content

    public enum Axis: String, Sendable { case vertical, horizontal }

    public init(_ axis: Axis = .vertical, @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.content = content()
    }

    public typealias Body = Never
}

extension ScrollView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "ScrollView",
            id: context.path,
            props: ["axis": .string(axis.rawValue)],
            children: Evaluator.resolveChildren(content, context.descending("content"))
        )
    }
}

/// A color used as a view fills its proposed space.
extension Color: View {
    public typealias Body = Never
}

extension Color: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(type: "Color", id: context.path, props: ["color": propValue])
    }
}

/// An image. `Image(systemName:)` maps a curated set of SF Symbol names to
/// Material icons in the interpreter; a named asset stays placeholder-level
/// until an asset pipeline exists.
public struct Image: View {

    internal let name: String
    internal let systemName: String?

    public init(_ name: String) {
        self.name = name
        self.systemName = nil
    }

    public init(systemName: String) {
        self.name = systemName
        self.systemName = systemName
    }

    public typealias Body = Never
}

extension Image: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = ["name": .string(name)]
        if let systemName { props["systemName"] = .string(systemName) }
        return RenderNode(type: "Image", id: context.path, props: props)
    }
}

/// Progress: indeterminate (spinner) or fractional (bar).
public struct ProgressView: View {

    internal let value: Double?

    public init() {
        self.value = nil
    }

    public init<V: BinaryFloatingPoint>(value: V?, total: V = 1.0) {
        self.value = value.map { Double($0 / total) }
    }

    public typealias Body = Never
}

extension ProgressView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = [:]
        if let value { props["value"] = .double(value) }
        return RenderNode(type: "ProgressView", id: context.path, props: props)
    }
}

/// A control for selecting a value from a bounded range.
public struct Slider: View {

    internal let value: Binding<Double>
    internal let minimum: Double
    internal let maximum: Double

    public init<V: BinaryFloatingPoint>(value: Binding<V>, in bounds: ClosedRange<V> = 0...1) {
        self.value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = V($0) }
        )
        self.minimum = Double(bounds.lowerBound)
        self.maximum = Double(bounds.upperBound)
    }

    public typealias Body = Never
}

extension Slider: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = value
        let callbackID = context.callbacks.register(.double { binding.wrappedValue = $0 })
        return RenderNode(
            type: "Slider",
            id: context.path,
            props: [
                "value": .double(value.wrappedValue),
                "min": .double(minimum),
                "max": .double(maximum),
                "onChange": .int(Int(callbackID)),
            ]
        )
    }
}

/// An editable text field bound to a string.
public struct TextField: View {

    internal let placeholder: String
    internal let text: Binding<String>

    public init<S: StringProtocol>(_ placeholder: S, text: Binding<String>) {
        self.placeholder = String(placeholder)
        self.text = text
    }

    public typealias Body = Never
}

extension TextField: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = text
        let callbackID = context.callbacks.register(.string { binding.wrappedValue = $0 })
        return RenderNode(
            type: "TextField",
            id: context.path,
            props: [
                "text": .string(text.wrappedValue),
                "placeholder": .string(placeholder),
                "onChange": .int(Int(callbackID)),
            ]
        )
    }
}

/// A text field that obscures its contents. Shares the TextField node with a
/// `secure` flag; the interpreter applies a password transformation.
public struct SecureField: View {

    internal let placeholder: String
    internal let text: Binding<String>

    public init<S: StringProtocol>(_ placeholder: S, text: Binding<String>) {
        self.placeholder = String(placeholder)
        self.text = text
    }

    public typealias Body = Never
}

extension SecureField: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let binding = text
        let callbackID = context.callbacks.register(.string { binding.wrappedValue = $0 })
        return RenderNode(
            type: "TextField",
            id: context.path,
            props: [
                "text": .string(text.wrappedValue),
                "placeholder": .string(placeholder),
                "onChange": .int(Int(callbackID)),
                "secure": .bool(true),
            ]
        )
    }
}

/// Eager stand-ins: laziness is an optimization the lazy container path (R7)
/// provides; semantics match the eager stacks.
public typealias LazyVStack = VStack
public typealias LazyHStack = HStack

/// An angle in degrees or radians.
public struct Angle: Equatable, Sendable {

    public var degrees: Double

    public init(degrees: Double) { self.degrees = degrees }

    public static func degrees(_ value: Double) -> Angle { Angle(degrees: value) }

    public static func radians(_ value: Double) -> Angle { Angle(degrees: value * 180 / .pi) }
}
