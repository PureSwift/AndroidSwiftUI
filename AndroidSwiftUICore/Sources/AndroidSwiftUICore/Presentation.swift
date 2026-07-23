//
//  Presentation.swift
//  AndroidSwiftUICore
//
//  Sheets and alerts: modal content presented over a screen, shown/hidden by a
//  bound flag. Drag-to-dismiss and the dialog buttons write the flag back
//  through a callback so Swift stays the source of truth.
//

/// Detent for a sheet's resting height.
public enum PresentationDetent: String, Sendable {
    case medium, large
}

/// Presents a sheet over its content while `isPresented` is true.
public struct _SheetView<Content: View, SheetBody: View>: View {

    internal let isPresented: Binding<Bool>
    internal let detents: [PresentationDetent]
    internal let content: Content
    internal let sheet: SheetBody

    public typealias Body = Never
}

extension _SheetView: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        var node = Evaluator.resolve(content, context.descending("content"))

        guard isPresented.wrappedValue else {
            return node
        }
        let binding = isPresented
        let dismissID = context.callbacks.register(.void { binding.wrappedValue = false })

        var sheetContext = context.descending("sheet")
        sheetContext.environment.values.dismiss = DismissAction { binding.wrappedValue = false }
        let sink = TitleSink()
        sheetContext.titleSink = sink
        let sheetNode = Evaluator.resolve(sheet, sheetContext)

        // carry the sheet as a hidden child the interpreter presents modally
        let presentation = RenderNode(
            type: "Sheet",
            id: context.path + "/sheet",
            props: [
                "onDismiss": .int(Int(dismissID)),
                "detents": .array(sink.detents.map { .string($0.rawValue) }),
            ],
            children: [sheetNode]
        )
        node.children.append(presentation)
        node.props["hasSheet"] = .bool(true)
        return node
    }
}

public extension View {
    func sheet<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> C
    ) -> _SheetView<Self, C> {
        _SheetView(isPresented: isPresented, detents: [], content: self, sheet: content())
    }
}

/// Sets a sheet's detents.
public struct _PresentationDetentsView<Content: View>: View {
    internal let detents: [PresentationDetent]
    internal let content: Content
    public typealias Body = Never
}

extension _PresentationDetentsView: _ResolutionEffectView {
    public func _applyEffect(_ context: inout ResolveContext) -> any View {
        context.titleSink?.detents = detents
        return content
    }
}

public extension View {
    func presentationDetents(_ detents: Set<PresentationDetent>) -> _PresentationDetentsView<Self> {
        _PresentationDetentsView(detents: Array(detents), content: self)
    }
}

// MARK: - Alert

/// A button in an alert.
public struct AlertButton {
    public enum Role { case normal, cancel, destructive }
    let title: String
    let role: Role
    let action: () -> Void

    public init(_ title: String, role: Role = .normal, action: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.action = action
    }
}

public struct _AlertView<Content: View>: View {
    internal let title: String
    internal let isPresented: Binding<Bool>
    internal let message: String?
    internal let buttons: [AlertButton]
    internal let content: Content
    public typealias Body = Never
}

extension _AlertView: PrimitiveView {

    public func _render(in context: ResolveContext) -> RenderNode {
        var node = Evaluator.resolve(content, context.descending("content"))
        guard isPresented.wrappedValue else { return node }

        let binding = isPresented
        var buttonNodes: [PropValue] = []
        for button in buttons {
            let action = button.action
            let id = context.callbacks.register(.void {
                action()
                binding.wrappedValue = false
            })
            buttonNodes.append(.array([
                .string(button.title),
                .string(role(button.role)),
                .int(Int(id)),
            ]))
        }
        let dismissID = context.callbacks.register(.void { binding.wrappedValue = false })

        var props: [String: PropValue] = [
            "title": .string(title),
            "buttons": .array(buttonNodes),
            "onDismiss": .int(Int(dismissID)),
        ]
        if let message { props["message"] = .string(message) }

        node.children.append(RenderNode(type: "Alert", id: context.path + "/alert", props: props))
        node.props["hasAlert"] = .bool(true)
        return node
    }

    private func role(_ role: AlertButton.Role) -> String {
        switch role {
        case .normal: return "normal"
        case .cancel: return "cancel"
        case .destructive: return "destructive"
        }
    }
}

public extension View {
    func alert<S: StringProtocol>(
        _ title: S,
        isPresented: Binding<Bool>,
        message: String? = nil,
        buttons: [AlertButton] = [AlertButton("OK")]
    ) -> _AlertView<Self> {
        _AlertView(title: String(title), isPresented: isPresented, message: message, buttons: buttons, content: self)
    }
}
