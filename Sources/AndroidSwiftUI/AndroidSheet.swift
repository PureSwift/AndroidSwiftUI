//
//  AndroidSheet.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import AndroidKit

extension _SheetPresenter: AndroidPrimitive {

    var renderedBody: AnyView {
        AnyView(AndroidSheetContainer(presenter: self))
    }
}

/// Native container for `.sheet(isPresented:onDismiss:content:)`.
///
/// The sheet is rendered as an overlay rather than an Android `Dialog`: the fiber renderer mounts
/// children by adding them to their parent `ViewGroup`, so the presented content has to live in the
/// same view hierarchy as the presenting content. `BackHandlerView` is a `FrameLayout`, so the sheet
/// content is stacked on top of the host content and the system back button is intercepted while the
/// sheet is presented.
struct AndroidSheetContainer<Content: View> {

    let presenter: _SheetPresenter<Content>
}

extension AndroidSheetContainer: ParentView {

    var children: [AnyView] {
        var views = [AnyView(presenter.content)]
        if presenter.isSheetPresented {
            views.append(AnyView(AndroidSheetOverlay(content: presenter.sheetContent())))
        }
        return views
    }
}

extension AndroidSheetContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> BackHandlerView {
        let presenter = self.presenter
        let view = BackHandlerView(context.androidContext) {
            presenter.dismiss()
        }
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: BackHandlerView, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidSheetContainer {

    func updateView(_ view: BackHandlerView) {
        // only intercept the back button while the sheet is on screen
        view.setBackHandlerEnabled(presenter.isSheetPresented)
    }
}

/// Opaque, full size container for the presented sheet content, stacked above the presenting content.
struct AndroidSheetOverlay {

    let content: AnyView
}

extension AndroidSheetOverlay: ParentView {

    var children: [AnyView] {
        [content]
    }
}

extension AndroidSheetOverlay: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.FrameLayout {
        let androidContext = context.androidContext
        let view = AndroidWidget.FrameLayout(androidContext)
        let matchParent = try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT
        view.setLayoutParams(ViewGroup.LayoutParams(matchParent, matchParent))
        view.setBackgroundColor(Self.backgroundColor(androidContext))
        // swallow touches so the presenting content underneath is not interactive
        view.setClickable(true)
        view.setFocusable(true)
        // draw above the presenting content
        view.setElevation(16)
        view.bringToFront()
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.FrameLayout, context: Self.Context) {
        view.bringToFront()
    }
}

private extension AndroidSheetOverlay {

    /// The theme's window background, so the sheet is opaque in both light and dark themes.
    static func backgroundColor(_ context: AndroidContent.Context) -> Int32 {
        let opaqueWhite = Int32(bitPattern: 0xFF_FF_FF_FF)
        guard let theme = context.getTheme() else {
            return opaqueWhite
        }
        let value = AndroidUtil.TypedValue()
        let attribute = try! JavaClass<AndroidR.R.attr>().colorBackground
        guard theme.resolveAttribute(attribute, value, true) else {
            return opaqueWhite
        }
        return value.data
    }
}
