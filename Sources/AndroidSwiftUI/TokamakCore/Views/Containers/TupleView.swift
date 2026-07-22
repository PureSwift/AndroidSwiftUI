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
//  Created by Max Desiatov on 08/04/2020.
//

/// A `View` created from a `Tuple` of `View` values.
///
/// Mainly for use with `@ViewBuilder`.
public struct TupleView<T>: _PrimitiveView {
  public let value: T

  let _children: [AnyView]
  private let visit: (ViewVisitor) -> ()

  public init(_ value: T) {
    self.value = value
    _children = []
    visit = { _ in }
  }

  public init(_ value: T, children: [AnyView]) {
    self.value = value
    _children = children
    visit = {
      for child in children {
        $0.visit(child)
      }
    }
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visit(visitor)
  }

  /// Creates a tuple view from an arbitrary number of child views.
  ///
  /// Children are visited through their type-erased form, matching the behaviour of the
  /// `children:` initializer above.
  init<each V: View>(views: repeat each V) where T == (repeat each V) {
    var children = [AnyView]()
    repeat children.append(AnyView(each views))
    value = (repeat each views)
    _children = children
    visit = { visitor in
      for child in children {
        visitor.visit(child)
      }
    }
  }
}

extension TupleView: GroupView {
  public var children: [AnyView] { _children }
}
