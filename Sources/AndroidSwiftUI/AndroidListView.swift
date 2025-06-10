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
        //let adapter = view.getAdapter().as(ArrayAdapter<JavaString>.self) as! ArrayAdapter<JavaString>
        //adapter.clear()
        let adapter = ArrayAdapter<JavaString>()
        for item in self.items {
            adapter.add(JavaString(item))
        }
        view.setAdapter(adapter.as(Adapter.self))
    }
}
