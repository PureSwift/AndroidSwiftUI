//
//  Sheet.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

/// Presents a sheet when a binding to a Boolean value that you provide is `true`.
///
/// The sheet content is mounted as a child of the presenting view's container and is unmounted
/// when `isPresented` becomes `false`. Sheet content can dismiss itself by calling the `dismiss`
/// environment action (read with `@Environment(\.dismiss)`), or by capturing and mutating
/// `isPresented`. Dismissal by any path — including the system back button — resets the binding
/// and invokes `onDismiss`.
public extension View {

    func sheet<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        _SheetPresenter(
            content: self,
            isPresented: isPresented,
            onDismiss: onDismiss,
            sheetContent: { AnyView(content()) }
        )
    }

    func sheet<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        let isPresented = Binding<Bool>(
            get: { item.wrappedValue != nil },
            set: { newValue in
                if newValue == false {
                    item.wrappedValue = nil
                }
            }
        )
        return _SheetPresenter(
            content: self,
            isPresented: isPresented,
            onDismiss: onDismiss,
            sheetContent: {
                if let value = item.wrappedValue {
                    return AnyView(content(value))
                } else {
                    return AnyView(EmptyView())
                }
            }
        )
    }
}

/// The view that hosts both the presenting content and, while presented, the sheet content.
///
/// This is a primitive view; renderers are expected to render `content` and, when
/// `isPresented.wrappedValue` is `true`, `sheetContent` on top of it.
public struct _SheetPresenter<Content>: _PrimitiveView where Content: View {

    public let content: Content

    public let isPresented: Binding<Bool>

    public let onDismiss: (() -> ())?

    public let sheetContent: () -> AnyView

    init(
        content: Content,
        isPresented: Binding<Bool>,
        onDismiss: (() -> ())?,
        sheetContent: @escaping () -> AnyView
    ) {
        self.content = content
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.sheetContent = sheetContent
    }

    /// Whether the sheet is currently presented.
    public var isSheetPresented: Bool {
        isPresented.wrappedValue
    }

    /// Dismisses the sheet, resetting the binding and invoking `onDismiss`.
    public func dismiss() {
        guard isPresented.wrappedValue else { return }
        isPresented.wrappedValue = false
        onDismiss?()
    }
}
