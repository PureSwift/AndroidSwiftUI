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

/// A view that displays a root view and enables you to present additional views over the root view.
///
///     NavigationStack {
///       NavigationLink("Details", destination: DetailView())
///     }
///
/// Pushes and pops are driven by the same `NavigationContext` used by `NavigationView`, so
/// `NavigationLink` and the system back button behave identically inside either container.
public struct NavigationStack<Root>: _PrimitiveView where Root: View {
  let root: Root

  /// Bridge to the bound navigation path for value-based navigation, or `nil` when
  /// navigation is driven by `NavigationLink(destination:)` pushes.
  let pathStore: _AnyNavigationPathStore?

  @StateObject
  var context = NavigationContext()

  public init(@ViewBuilder root: () -> Root) {
    self.root = root()
    pathStore = nil
  }

  /// Creates a navigation stack with heterogeneous navigation state that you can control.
  ///
  /// Appending to the bound `NavigationPath` pushes the destination registered with
  /// `navigationDestination(for:destination:)` for the appended value's type; removing
  /// values pops, as does the system back button.
  public init(path: Binding<NavigationPath>, @ViewBuilder root: () -> Root) {
    self.root = root()
    pathStore = _AnyNavigationPathStore(path)
  }

  /// Creates a navigation stack with homogeneous navigation state that you can control.
  public init<Data>(path: Binding<Data>, @ViewBuilder root: () -> Root)
    where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
    Data.Element: Hashable
  {
    self.root = root()
    pathStore = _AnyNavigationPathStore(path)
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _NavigationStackProxy<Root: View> {
  public let subject: NavigationStack<Root>

  public init(_ subject: NavigationStack<Root>) { self.subject = subject }

  public var context: NavigationContext {
    // keep the context's bridge to the bound path current across renders
    subject.context.pathStore = subject.pathStore
    return subject.context
  }

  public var content: some View {
    subject.root
      .environmentObject(context)
  }

  /// The currently visible screen: the root content if the stack is empty,
  /// otherwise the top of `context.path`.
  public var currentView: AnyView {
    context.path.isEmpty ? AnyView(content) : AnyView(destination)
  }

  /// The pushed destinations to display above the root, in order from bottom to top,
  /// with the `dismiss` environment action wired to pop.
  public var pushedViews: [AnyView] {
    let context = self.context
    let pushed: [AnyView]
    if let store = subject.pathStore {
      let values = store.elements()
      guard !values.isEmpty else { return [] }
      let resolved = values.compactMap { context.destinationView(for: $0) }
      guard resolved.count == values.count else {
        // destination builders register during the root's body evaluation, so a
        // pre-populated path cannot resolve on the very first render; retry once
        // the content has rendered
        if context.destinationBuilders.isEmpty {
          Task { @MainActor [weak context] in
            context?.objectWillChange.send()
          }
        }
        return []
      }
      pushed = resolved.map { AnyView($0.environmentObject(context)) }
    } else {
      pushed = context.path.map { AnyView($0.view.environmentObject(context)) }
    }
    return pushed.map { view in
      AnyView(
        view
          .environment(\.dismiss, DismissAction { context.pop() })
          .environment(\.isPresented, true)
      )
    }
  }

  /// The topmost pushed destination, if any.
  public var pushedView: AnyView? {
    pushedViews.last
  }

  public var destination: some View {
    subject.context.destination.view
      .environmentObject(context)
  }
}
