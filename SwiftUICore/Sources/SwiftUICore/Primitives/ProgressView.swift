//
//  ProgressView.swift
//  SwiftUICore
//
//  Progress with an optional label. Determinacy and shape are independent:
//  whether a value is present decides determinate vs. indeterminate, while
//  `progressViewStyle` decides linear vs. circular. The default infers a shape
//  from determinacy (linear when a value is known, circular when not), which is
//  what the original value-only implementation always did.
//

public struct ProgressView<Label: View>: View {

    internal let value: Double?
    internal let label: Label

    public init(value: Double? = nil, @ViewBuilder label: () -> Label) {
        self.value = value
        self.label = label()
    }

    public typealias Body = Never
}

public extension ProgressView where Label == EmptyView {

    init() {
        self.init(value: nil) { EmptyView() }
    }

    init<V: BinaryFloatingPoint>(value: V?, total: V = 1.0) {
        self.init(value: value.map { Double($0 / total) }) { EmptyView() }
    }
}

public extension ProgressView where Label == Text {

    init<S: StringProtocol>(_ title: S) {
        self.init(value: nil) { Text(title) }
    }

    init<S: StringProtocol, V: BinaryFloatingPoint>(_ title: S, value: V?, total: V = 1.0) {
        self.init(value: value.map { Double($0 / total) }) { Text(title) }
    }
}

extension ProgressView: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        var props: [String: PropValue] = [:]
        if let value { props["value"] = .double(value) }
        return RenderNode(
            type: "ProgressView",
            id: context.path,
            props: props,
            children: Evaluator.resolveChildren(label, context.descending("label"))
        )
    }
}

// MARK: - Style

/// The built-in progress shapes. This is the `.circular` / `.linear` spelling
/// only — the `ProgressViewStyle` protocol for custom styles isn't modeled.
public struct _ProgressViewStyle: Sendable {

    internal let kind: String

    public static let automatic = _ProgressViewStyle(kind: "automatic")
    public static let linear = _ProgressViewStyle(kind: "linear")
    public static let circular = _ProgressViewStyle(kind: "circular")
}

public struct _ProgressViewStyleModifier: RenderModifier {
    let style: _ProgressViewStyle
    public var _modifierNode: ModifierNode {
        ModifierNode(kind: "progressViewStyle", args: ["style": .string(style.kind)])
    }
}

public extension View {
    func progressViewStyle(_ style: _ProgressViewStyle) -> ModifiedContent<Self, _ProgressViewStyleModifier> {
        modifier(_ProgressViewStyleModifier(style: style))
    }
}
