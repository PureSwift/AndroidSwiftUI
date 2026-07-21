// Copyright 2020-2021 Tokamak contributors
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

/// Stores an `Observable` object in the environment, keyed by its type, so it can be
/// read back with `@Environment(ObjectType.self)`.
public struct _ObservableEnvironmentWritingModifier<ObjectType>: ViewModifier, _EnvironmentModifier
  where ObjectType: AnyObject & Observable
{
  public let object: ObjectType?

  public init(object: ObjectType?) {
    self.object = object
  }

  public typealias Body = Never

  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values[observable: ObjectIdentifier(ObjectType.self)] = object
  }
}

public extension View {
  /// Places an `Observable` object in the view's environment, where it can be read
  /// by descendants with `@Environment(ObjectType.self)`.
  func environment<T>(_ object: T?) -> some View where T: AnyObject & Observable {
    modifier(_ObservableEnvironmentWritingModifier(object: object))
  }
}
