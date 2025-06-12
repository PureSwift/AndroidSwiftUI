//
//  ListView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

/// SwitUI View for Android `android.widget.ListView`
public struct AndroidListView {
    
    let items: [String]
        
    public init<C>(_ data: C, @ViewBuilder content: (C.Element) -> Text) where C: Collection, C.Element: Identifiable {
        self.items = data.map { _TextProxy(content($0)).rawText }
    }
}

extension AndroidListView: AndroidViewRepresentable {
    
    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> ListView {
        createView(context: context.androidContext)
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: ListView, context: Self.Context) {
        updateView(view)
    }
}

extension AndroidListView {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.ListView {
        let view = AndroidWidget.ListView(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.ListView) {
        let layout = try! JavaClass<R.layout>()
        let resource = layout.simple_list_item_1
        let objects: [JavaObject?] = items.map { JavaString($0) }
        let adapter = ArrayAdapter<JavaObject>(
            context: view.getContext(),
            resource: resource,
            objects: objects
        )
        view.setAdapter(adapter.as(Adapter.self))
    }
}

extension JavaClass<R.layout> {
    
    @JavaStaticField(isFinal: true)
    public var list_view_row: Int32
}

extension JavaClass<R.id> {
    
    @JavaStaticField(isFinal: true)
    public var textView: Int32
}
