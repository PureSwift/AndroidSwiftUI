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
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import Foundation

/// A view that arranges its children in a vertical line, creating them as needed.
///
///     LazyVStack {
///       Text("Hello")
///       Text("World")
///     }
///
/// Children are currently created eagerly and laid out with the same Android `LinearLayout` used by
/// `VStack`: laziness is a performance optimisation, not a semantic requirement, so the rendered
/// result is identical to `VStack`.
public struct LazyVStack<Content>: _PrimitiveView where Content: View {
  public let alignment: HorizontalAlignment

  @_spi(TokamakCore)
  public let spacing: CGFloat?

  public let pinnedViews: PinnedScrollableViews

  public let content: Content

  public init(
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

extension LazyVStack: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _LazyVStackProxy<Content> where Content: View {
  public let subject: LazyVStack<Content>

  public init(_ subject: LazyVStack<Content>) { self.subject = subject }

  public var content: Content { subject.content }
  public var spacing: CGFloat { subject.spacing ?? defaultStackSpacing }
}

/// A view that arranges its children in a horizontal line, creating them as needed.
///
///     LazyHStack {
///       Text("Hello")
///       Text("World")
///     }
///
/// Children are currently created eagerly and laid out with the same Android `LinearLayout` used by
/// `HStack`: laziness is a performance optimisation, not a semantic requirement, so the rendered
/// result is identical to `HStack`.
public struct LazyHStack<Content>: _PrimitiveView where Content: View {
  public let alignment: VerticalAlignment

  @_spi(TokamakCore)
  public let spacing: CGFloat?

  public let pinnedViews: PinnedScrollableViews

  public let content: Content

  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

extension LazyHStack: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _LazyHStackProxy<Content> where Content: View {
  public let subject: LazyHStack<Content>

  public init(_ subject: LazyHStack<Content>) { self.subject = subject }

  public var content: Content { subject.content }
  public var spacing: CGFloat { subject.spacing ?? defaultStackSpacing }
}
