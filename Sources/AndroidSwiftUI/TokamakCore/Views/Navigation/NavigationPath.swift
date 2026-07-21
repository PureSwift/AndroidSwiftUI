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

/// A type-erased list of data representing the content of a navigation stack.
///
/// Bind a `NavigationPath` to a `NavigationStack` to drive value-based navigation:
/// appending a value pushes the destination registered with
/// `navigationDestination(for:destination:)` for that value's type, and removing
/// values pops. The codable representation for state restoration is not yet supported.
public struct NavigationPath: Equatable {

  var elements: [AnyHashable]

  /// Creates an empty navigation path.
  public init() {
    elements = []
  }

  /// Creates a navigation path from a sequence of hashable elements.
  public init<S>(_ elements: S) where S: Sequence, S.Element: Hashable {
    self.elements = elements.map { AnyHashable($0) }
  }

  /// The number of elements in the path.
  public var count: Int {
    elements.count
  }

  /// Whether the path is empty.
  public var isEmpty: Bool {
    elements.isEmpty
  }

  /// Appends a new value to the end of the path.
  public mutating func append<V>(_ value: V) where V: Hashable {
    elements.append(AnyHashable(value))
  }

  /// Removes values from the end of the path.
  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(Swift.min(k, elements.count))
  }
}

/// Type-erased access to a navigation path binding, bridging both
/// `Binding<NavigationPath>` and `Binding<Data>` stacks to the shared
/// `NavigationContext`.
struct _AnyNavigationPathStore {

  let count: () -> Int

  let last: () -> AnyHashable?

  let elements: () -> [AnyHashable]

  let append: (AnyHashable) -> ()

  let removeLast: () -> ()

  init(_ path: Binding<NavigationPath>) {
    count = { path.wrappedValue.count }
    last = { path.wrappedValue.elements.last }
    elements = { path.wrappedValue.elements }
    append = { path.wrappedValue.elements.append($0) }
    removeLast = { path.wrappedValue.removeLast() }
  }

  init<Data>(_ path: Binding<Data>)
    where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
    Data.Element: Hashable
  {
    count = { path.wrappedValue.count }
    last = { path.wrappedValue.last.map { AnyHashable($0) } }
    elements = { path.wrappedValue.map { AnyHashable($0) } }
    append = { value in
      guard let element = value.base as? Data.Element else { return }
      path.wrappedValue.append(element)
    }
    removeLast = {
      guard !path.wrappedValue.isEmpty else { return }
      path.wrappedValue.removeLast()
    }
  }
}
