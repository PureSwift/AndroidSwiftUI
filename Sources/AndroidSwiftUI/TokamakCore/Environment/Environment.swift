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

import Observation

/// A protocol that allows the conforming type to access values from the `EnvironmentValues`.
/// (e.g. `Environment` and `EnvironmentObject`)
///
/// `EnvironmentValues` are injected in 2 places:
/// 1. `View.makeMountedView`
/// 2. `MountedHostView.update` when reconciling
///
protocol EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues)
}

@propertyWrapper
public struct Environment<Value>: DynamicProperty {
  enum Content {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case value(Value)
    /// An `Observable` object that hasn't been resolved from the environment (yet).
    case observableType(Any.Type)
  }

  /// Describes where the value of this property should be read from.
  enum Source {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case observableType(Any.Type)
  }

  private var content: Content
  private let source: Source

  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    content = .keyPath(keyPath)
    source = .keyPath(keyPath)
  }

  /// Creates an environment property that reads an `Observable` object injected
  /// with `View.environment(_:)`.
  init(observableType: Any.Type) {
    content = .observableType(observableType)
    source = .observableType(observableType)
  }

  mutating func setContent(from values: EnvironmentValues) {
    switch source {
    case let .keyPath(keyPath):
      content = .value(values[keyPath: keyPath])
    case let .observableType(objectType):
      // Leave the content unresolved when nothing was injected, so that
      // `wrappedValue` traps with a descriptive message like SwiftUI does.
      guard let object = values[observable: ObjectIdentifier(objectType)] as? Value else {
        content = .observableType(objectType)
        return
      }
      content = .value(object)
    }
  }

  public var wrappedValue: Value {
    switch content {
    case let .value(value):
      return value
    case let .keyPath(keyPath):
      // not bound to a view, return the default value.
      return EnvironmentValues()[keyPath: keyPath]
    case let .observableType(objectType):
      fatalError(
        """
        No Observable object of type \(objectType) found. \
        A View.environment(_:) for \(objectType) may be missing as an ancestor of this view.
        """
      )
    }
  }
}

public extension Environment where Value: AnyObject & Observable {
  /// Creates an environment property that reads the `Observable` object of the
  /// given type injected with `View.environment(_:)`.
  init(_ objectType: Value.Type) {
    self.init(observableType: objectType)
  }
}

extension Environment: EnvironmentReader {}
