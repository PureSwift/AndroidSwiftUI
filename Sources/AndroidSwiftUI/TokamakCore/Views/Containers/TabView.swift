// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

/// A view that switches between multiple child views using interactive user interface elements.
public struct TabView<SelectionValue, Content>: _PrimitiveView
  where SelectionValue: Hashable, Content: View
{
  let content: Content

  let selection: Binding<SelectionValue>?

  /// Index of the selected tab when no `selection` binding was provided.
  @State
  var selectedIndex: Int = 0

  public init(
    selection: Binding<SelectionValue>?,
    @ViewBuilder content: () -> Content
  ) {
    self.selection = selection
    self.content = content()
  }
}

public extension TabView where SelectionValue == Int {
  init(@ViewBuilder content: () -> Content) {
    self.init(selection: nil, content: content)
  }
}

// MARK: - Tab Item

/// The label of a tab, as set by the `tabItem(_:)` modifier.
struct TabItemTraitKey: _ViewTraitKey {
  typealias Value = AnyView?

  static var defaultValue: AnyView? { nil }
}

public extension View {
  /// Sets the tab bar item used to represent this view inside a `TabView`.
  func tabItem<V>(@ViewBuilder _ label: () -> V) -> some View where V: View {
    _trait(TabItemTraitKey.self, AnyView(label()))
  }
}

/// A single tab of a `TabView`: the view to display when selected, the label to show in the tab
/// bar, and the value matched against the selection binding.
public struct _TabViewItem {
  /// The view mounted when this tab is selected.
  public let content: AnyView

  /// The label displayed in the tab bar, if `tabItem(_:)` was applied.
  public let label: AnyView?

  /// The value provided by `tag(_:)`, if any.
  public let tag: AnyHashable?
}

// MARK: - Proxy

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _TabViewProxy<SelectionValue, Content>
  where SelectionValue: Hashable, Content: View
{
  public let subject: TabView<SelectionValue, Content>

  public init(_ subject: TabView<SelectionValue, Content>) { self.subject = subject }

  /// The tabs declared by the `TabView`'s content, in declaration order.
  public var items: [_TabViewItem] {
    Self.tabs(of: AnyView(subject.content)).map { child in
      let attributes = Self.attributes(of: child.view)
      return _TabViewItem(content: child, label: attributes.label, tag: attributes.tag)
    }
  }

  /// The index of the currently selected tab, clamped to the available tabs.
  public var selectedIndex: Int {
    Self.index(ofSelectionIn: items, of: subject)
  }

  /// The content of the currently selected tab, or an empty view if there are no tabs.
  public var selectedContent: AnyView {
    let items = self.items
    let index = Self.index(ofSelectionIn: items, of: subject)
    guard items.indices.contains(index) else { return AnyView(EmptyView()) }
    return items[index].content
  }

  /// Selects the tab at the given index, updating the selection binding when one was provided,
  /// and the internal state otherwise.
  public func select(_ index: Int) {
    let items = self.items
    guard items.indices.contains(index) else { return }
    guard let selection = subject.selection else {
      subject.selectedIndex = index
      return
    }
    if let tag = items[index].tag?.base as? SelectionValue {
      selection.wrappedValue = tag
    } else if let index = index as? SelectionValue {
      // untagged tabs of an `Int`-selected `TabView` are identified by their index
      selection.wrappedValue = index
    }
  }
}

private extension _TabViewProxy {
  /// Flattens the content of the `TabView` into one view per tab, descending into
  /// "flattened" views such as `TupleView`, `Group` and `ForEach`.
  static func tabs(of view: AnyView) -> [AnyView] {
    // a view that declares its own tab item is always a single tab, even if it is a group
    guard attributes(of: view.view).label == nil,
          let group = view.view as? GroupView
    else { return [view] }
    return group.children.flatMap { tabs(of: $0) }
  }

  /// Walks the modifiers applied to a tab, collecting the values written by `tabItem(_:)`
  /// and `tag(_:)`.
  static func attributes(of view: Any) -> (label: AnyView?, tag: AnyHashable?) {
    var label: AnyView?
    var tag: AnyHashable?
    var view = view
    while let modified = view as? _AnyModifiedContent {
      if let modifier = modified.anyModifier as? _TraitWritingModifier<TabItemTraitKey> {
        label = label ?? modifier.value
      } else if let modifier = modified
        .anyModifier as? _TraitWritingModifier<TagValueTraitKey<SelectionValue>>,
        case let .tagged(value) = modifier.value
      {
        tag = tag ?? AnyHashable(value)
      }
      view = modified.anyContent
    }
    return (label, tag)
  }

  static func index(
    ofSelectionIn items: [_TabViewItem],
    of subject: TabView<SelectionValue, Content>
  ) -> Int {
    guard !items.isEmpty else { return 0 }
    guard let selection = subject.selection else {
      return min(max(subject.selectedIndex, 0), items.count - 1)
    }
    let value = AnyHashable(selection.wrappedValue)
    if let index = items.firstIndex(where: { $0.tag == value }) {
      return index
    } else if let index = value.base as? Int, items.indices.contains(index) {
      // untagged tabs of an `Int`-selected `TabView` are identified by their index
      return index
    } else {
      return 0
    }
  }
}

// MARK: - Modifier Introspection

/// Type-erased access to a `ModifiedContent`, so the modifiers applied to a tab can be
/// inspected without knowing their generic parameters.
protocol _AnyModifiedContent {
  var anyContent: Any { get }

  var anyModifier: Any { get }
}

extension ModifiedContent: _AnyModifiedContent {
  var anyContent: Any { content }

  var anyModifier: Any { modifier }
}
