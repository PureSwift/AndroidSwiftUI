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
//  Created by Jed Fox on 06/30/2020.
//

public final class NavigationContext: ObservableObject {
  @Published
  var destination = NavigationLinkDestination(EmptyView())

  /// The stack of pushed destinations, not including the root content.
  @Published
  private(set) var path: [NavigationLinkDestination] = []

  /// Destination builders registered with `navigationDestination(for:destination:)`,
  /// keyed by the type of the value they present. Not published: builders are
  /// (re)registered during body evaluation and must not invalidate the view.
  var destinationBuilders: [ObjectIdentifier: (AnyHashable) -> AnyView] = [:]

  /// Bridge to the path binding of a value-driven `NavigationStack(path:)`, or `nil`
  /// when navigation is driven by pushed destination views. Not published: the owning
  /// stack refreshes it on every render.
  var pathStore: _AnyNavigationPathStore?

  /// Whether any destination is currently pushed, by either navigation mechanism.
  var hasPushedDestinations: Bool {
    !path.isEmpty || (pathStore?.count() ?? 0) > 0
  }

  func push(_ destination: NavigationLinkDestination) {
    path.append(destination)
    self.destination = destination
  }

  /// Pushes a value: appends to the path binding when one is bound, otherwise
  /// resolves the registered destination and pushes the resulting view.
  func push(value: AnyHashable) {
    if let pathStore {
      pathStore.append(value)
    } else if let view = destinationView(for: value) {
      push(NavigationLinkDestination(view))
    }
  }

  /// Resolves the destination view registered for the type of `value`.
  func destinationView(for value: AnyHashable) -> AnyView? {
    destinationBuilders[ObjectIdentifier(type(of: value.base))]?(value)
  }

  @discardableResult
  public func pop() -> Bool {
    if let pathStore, pathStore.count() > 0 {
      pathStore.removeLast()
      return true
    }
    guard !path.isEmpty else { return false }
    path.removeLast()
    destination = path.last ?? NavigationLinkDestination(EmptyView())
    return true
  }
}

public struct NavigationView<Content>: _PrimitiveView where Content: View {
  let content: Content

  @StateObject
  var context = NavigationContext()

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

private struct ToolbarReader<Content>: View where Content: View {
  let content: (_ title: AnyView?, _ toolbarContent: [AnyToolbarItem]?) -> Content

  var body: some View {
    ToolbarKey._delay {
      $0._force { bar in
        NavigationTitleKey._delay {
          $0
            ._force {
              content($0, bar.items.isEmpty && $0 == nil ? nil : bar.items)
            }
        }
      }
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _NavigationViewProxy<Content: View> {
  public let subject: NavigationView<Content>

  public init(_ subject: NavigationView<Content>) { self.subject = subject }

  public var context: NavigationContext { subject.context }

  /// Builds the content of the `NavigationView` by passing in the title and toolbar if present.
  /// If `toolbarContent` is `nil`, you shouldn't render a toolbar.
  public func makeToolbar<DeferredBar>(
    @ViewBuilder _ content: @escaping (_ title: AnyView?, _ toolbarContent: [AnyToolbarItem]?)
      -> DeferredBar
  ) -> some View where DeferredBar: View {
    ToolbarReader(content: content)
  }

  public var content: some View {
    subject.content
      .environmentObject(context)
  }

  /// The currently visible screen: the root `content` if the stack is empty, otherwise the top of `context.path`.
  public var currentView: AnyView {
    context.path.isEmpty ? AnyView(content) : AnyView(destination)
  }

  /// The pushed destination to display above the root, if any, with the `dismiss`
  /// environment action wired to pop.
  public var pushedView: AnyView? {
    guard !context.path.isEmpty else { return nil }
    let context = self.context
    return AnyView(
      destination
        .environment(\.dismiss, DismissAction { context.pop() })
        .environment(\.isPresented, true)
    )
  }

  public var destination: some View {
    subject.context.destination.view
      .environmentObject(context)
  }
}

struct NavigationDestinationKey: EnvironmentKey {
  public static let defaultValue: Binding<AnyView>? = nil
}

extension EnvironmentValues {
  var navigationDestination: Binding<AnyView>? {
    get {
      self[NavigationDestinationKey.self]
    }
    set {
      self[NavigationDestinationKey.self] = newValue
    }
  }
}

struct NavigationTitleKey: PreferenceKey {
  typealias Value = AnyView?
  static func reduce(value: inout AnyView?, nextValue: () -> AnyView?) {
    value = nextValue()
  }
}

struct NavigationBarItemKey: PreferenceKey {
  static let defaultValue: NavigationBarItem = .init(displayMode: .automatic)
  static func reduce(value: inout NavigationBarItem, nextValue: () -> NavigationBarItem) {
    value = nextValue()
  }
}
