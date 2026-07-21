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

  @StateObject
  var context = NavigationContext()

  public init(@ViewBuilder root: () -> Root) {
    self.root = root()
  }

  // `NavigationStack(path:)` and the `navigationDestination(for:destination:)` value-based
  // navigation APIs are not yet supported.
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _NavigationStackProxy<Root: View> {
  public let subject: NavigationStack<Root>

  public init(_ subject: NavigationStack<Root>) { self.subject = subject }

  public var context: NavigationContext { subject.context }

  public var content: some View {
    subject.root
      .environmentObject(context)
  }

  /// The currently visible screen: the root content if the stack is empty,
  /// otherwise the top of `context.path`.
  public var currentView: AnyView {
    context.path.isEmpty ? AnyView(content) : AnyView(destination)
  }

  public var destination: some View {
    subject.context.destination.view
      .environmentObject(context)
  }
}
