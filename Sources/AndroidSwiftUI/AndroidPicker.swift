//
//  AndroidPicker.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/22/26.
//

import AndroidKit

extension _PickerContainer: AndroidPrimitive {

    var renderedBody: AnyView {
        let options = Self.options(of: self)
        return AnyView(AndroidSpinner(
            selection: $selection,
            titles: options.map(\.title),
            values: options.map(\.value)
        ))
    }
}

private extension _PickerContainer {

    struct Option {

        let title: String

        let value: SelectionValue
    }

    /// The pickable options, in order.
    ///
    /// `elements` covers the `ForEach`-with-data case, where the identity is the selection
    /// value. Otherwise the container's content — the generated `ForEach` of
    /// `_PickerElement`s that `Picker.body` builds, each wrapped in conditional content —
    /// is flattened, and each element's row is walked for the `tag(_:)` that associates it
    /// with its value.
    static func options(of container: Self) -> [Option] {
        if !container.elements.isEmpty {
            return container.elements.compactMap { element in
                guard let value = element.anyId.base as? SelectionValue else { return nil }
                return Option(title: title(of: element.anyContent), value: value)
            }
        }
        return pickerElements(in: AnyView(container.content)).compactMap { element in
            guard let value = tag(of: element.content.view) else { return nil }
            return Option(title: title(of: element.content), value: value)
        }
    }

    /// Recursively flattens group views to the `_PickerElement` rows they contain.
    /// `ForEach` wraps each row in an identified view, which is descended through its
    /// content.
    static func pickerElements(in view: AnyView) -> [_PickerElement] {
        if let element = mapAnyView(view, transform: { (element: _PickerElement) in element }) {
            return [element]
        }
        if let identified = view.view as? _AnyIDView {
            return pickerElements(in: identified.anyContent)
        }
        guard let group = view.view as? GroupView else { return [] }
        return group.children.flatMap { pickerElements(in: $0) }
    }

    /// The value written by `tag(_:)`, if any.
    static func tag(of view: Any) -> SelectionValue? {
        var view = view
        while let modified = view as? _AnyModifiedContent {
            if let modifier = modified.anyModifier as? _TraitWritingModifier<TagValueTraitKey<SelectionValue>>,
               case let .tagged(value) = modifier.value {
                return value
            }
            view = modified.anyContent
        }
        return nil
    }

    /// The text a row displays, unwrapping any modifiers (such as the tag itself) around
    /// it. Rows that aren't text render as an empty entry, since a spinner shows plain
    /// strings rather than arbitrary views.
    static func title(of view: AnyView) -> String {
        var view = view.view
        while let modified = view as? _AnyModifiedContent {
            view = modified.anyContent
        }
        return (view as? Text).map { _TextProxy($0).rawText } ?? ""
    }
}

/// Native spinner bound to the selected value.
struct AndroidSpinner<SelectionValue: Hashable> {

    @Binding
    var selection: SelectionValue

    let titles: [String]

    let values: [SelectionValue]
}

extension AndroidSpinner: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> AndroidWidget.Spinner {
        let view = AndroidWidget.Spinner(context.androidContext)
        // a spinner that hugs its content collapses to the dropdown arrow, hiding the
        // selected value; span the stack like the other horizontal controls
        view.setLayoutParams(ViewGroup.LayoutParams(
            try! JavaClass<ViewGroup.LayoutParams>().MATCH_PARENT,
            try! JavaClass<ViewGroup.LayoutParams>().WRAP_CONTENT
        ))
        applyAdapter(to: view, context: context.androidContext)
        // attached after the adapter so the initial selection doesn't call back
        let listener = SpinnerOnItemSelectedListener { position in
            guard let value = self.values.indices.contains(Int(position)) ? self.values[Int(position)] : nil,
                  value != self.selection else { return }
            self.selection = value
        }
        listener.attach(view)
        return view
    }

    func updateAndroidView(_ view: AndroidWidget.Spinner, context: Self.Context) {
        applyAdapter(to: view, context: view.getContext())
    }
}

private extension AndroidSpinner {

    func applyAdapter(to view: AndroidWidget.Spinner, context: AndroidContent.Context?) {
        guard let context else { return }
        let layout = try! JavaClass<AndroidR.R.layout>().simple_spinner_dropdown_item
        let adapter = AndroidWidget.ArrayAdapter<JavaObject>(
            context: context,
            resource: layout,
            objects: titles.map { JavaString($0).as(JavaObject.self) }
        )
        view.setAdapter(adapter.as(AndroidWidget.SpinnerAdapter.self))
        if let index = values.firstIndex(of: selection), view.getSelectedItemPosition() != Int32(index) {
            view.setSelection(Int32(index))
        }
    }
}
