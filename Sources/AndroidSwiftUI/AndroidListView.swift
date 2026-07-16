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
        return ComposeListView(context.androidContext, adapter)
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: ComposeListView, context: Self.Context) {
        guard let adapter = view.getAdapter() else {
            assertionFailure("Missing adapter")
            return
        }
        adapter.context = ListViewAdapter.Context(items: items)
        view.refresh()
    }
}
