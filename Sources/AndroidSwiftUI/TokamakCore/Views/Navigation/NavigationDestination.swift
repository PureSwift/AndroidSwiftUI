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

public extension View {
  /// Associates a destination view with a presented data type for use within a navigation stack.
  ///
  /// Add this modifier to a view inside a `NavigationStack` to describe the view to display
  /// when a value of the given type is pushed — by a `NavigationLink(value:label:)`, or by
  /// appending to a bound `NavigationPath` or data collection.
  func navigationDestination<D, C>(
    for data: D.Type,
    @ViewBuilder destination: @escaping (D) -> C
  ) -> some View where D: Hashable, C: View {
    _NavigationDestinationView(
      content: self,
      typeID: ObjectIdentifier(data),
      builder: { value in
        guard let value = value.base as? D else { return AnyView(EmptyView()) }
        return AnyView(destination(value))
      }
    )
  }
}

/// Registers a destination builder with the enclosing navigation context as part of body
/// evaluation, so builders are available whenever the stack resolves pushed values.
struct _NavigationDestinationView<Content>: View where Content: View {
  let content: Content
  let typeID: ObjectIdentifier
  let builder: (AnyHashable) -> AnyView

  @Environment(\.self)
  var environment: EnvironmentValues

  var body: some View {
    // registration is idempotent and writes a non-published property, so it cannot
    // invalidate the view; outside of a navigation container this is a no-op
    if let context: NavigationContext = environment[ObjectIdentifier(NavigationContext.self)] {
      context.destinationBuilders[typeID] = builder
    }
    return content
  }
}
