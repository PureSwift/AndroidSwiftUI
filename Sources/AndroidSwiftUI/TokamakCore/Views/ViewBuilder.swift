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

/// A `View` with no effect on rendering.
public struct EmptyView: _PrimitiveView {
  @inlinable
  public init() {}
}

// swiftlint:disable:next type_name
public struct _ConditionalContent<TrueContent, FalseContent>: _PrimitiveView
  where TrueContent: View, FalseContent: View
{
  enum Storage {
    case trueContent(TrueContent)
    case falseContent(FalseContent)
  }

  let storage: Storage

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    switch storage {
    case let .trueContent(view):
      visitor.visit(view)
    case let .falseContent(view):
      visitor.visit(view)
    }
  }
}

extension _ConditionalContent: GroupView {
  public var children: [AnyView] {
    switch storage {
    case let .trueContent(view):
      return [AnyView(view)]
    case let .falseContent(view):
      return [AnyView(view)]
    }
  }
}

extension Optional: View where Wrapped: View {
  public var body: some View {
    if let view = self {
      view
    } else {
      EmptyView()
    }
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    switch self {
    case .none:
      break
    case let .some(wrapped):
      visitor.visit(wrapped)
    }
  }
}

@_spi(TokamakCore)
public protocol AnyOptional {
  var value: Any? { get }
}

@_spi(TokamakCore)
extension Optional: AnyOptional {
  public var value: Any? {
    switch self {
    case let .some(value): return value
    case .none: return nil
    }
  }
}

@resultBuilder
public enum ViewBuilder {
  public static func buildBlock() -> EmptyView { EmptyView() }

  public static func buildBlock<Content>(
    _ content: Content
  ) -> Content where Content: View {
    content
  }

  public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
    content
  }

  public static func buildEither<TrueContent, FalseContent>(
    first: TrueContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .trueContent(first))
  }

  public static func buildEither<TrueContent, FalseContent>(
    second: FalseContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .falseContent(second))
  }
}

// swiftlint:disable large_tuple
// swiftlint:disable function_parameter_count

public extension ViewBuilder {
  /// Builds a block from an arbitrary number of child views.
  ///
  /// Parameter packs replace the fixed set of arity-specific overloads this file used to
  /// declare, which capped a view builder at ten children.
  static func buildBlock<each Content: View>(
    _ content: repeat each Content
  ) -> TupleView<(repeat each Content)> {
    TupleView(views: repeat each content)
  }
}
