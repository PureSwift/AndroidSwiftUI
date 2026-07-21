//
//  ListView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

/// SwiftUI `List` for Android, backed by a Jetpack Compose `LazyColumn`.
public struct AndroidListView {
    
    let items: [String]
        
    public init<C>(_ data: C, @ViewBuilder content: (C.Element) -> Text) where C: Collection, C.Element: Identifiable {
        self.items = data.map { _TextProxy(content($0)).rawText }
    }
}

extension AndroidListView: AndroidViewRepresentable {

    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> ComposeListView {
        let adapter = ListViewAdapter(swiftObject: SwiftObject(ListViewAdapter.Context(items: items)))
        let view = ComposeListView(context.androidContext, adapter)
        updateRefreshAction(for: view, context: context)
        return view
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: ComposeListView, context: Self.Context) {
        guard let adapter = view.getAdapter() else {
            assertionFailure("Missing adapter")
            return
        }
        adapter.context = ListViewAdapter.Context(items: items)
        updateRefreshAction(for: view, context: context)
        view.refresh()
    }
}

private extension AndroidListView {

    /// Wires the `refresh` environment value to the pull to refresh gesture.
    func updateRefreshAction(for view: ComposeListView, context: Self.Context) {
        guard let action = context.environment.refresh else {
            view.setOnRefresh(nil)
            return
        }
        let runnable = Runnable {
            Task { @MainActor in
                await action()
                view.endRefreshing()
            }
        }
        view.setOnRefresh(runnable)
    }
}
