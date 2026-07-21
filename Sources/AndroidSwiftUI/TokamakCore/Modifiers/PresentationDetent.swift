//
//  PresentationDetent.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/21/26.
//

import Foundation

/// A type that represents a height where a sheet naturally rests.
public struct PresentationDetent: Hashable {

  enum Storage: Hashable {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
  }

  let storage: Storage

  /// A detent for a sheet at half the height of the screen.
  public static let medium = PresentationDetent(storage: .medium)

  /// A detent for a full-height sheet.
  public static let large = PresentationDetent(storage: .large)

  /// A detent for a sheet at a fraction of the screen height.
  public static func fraction(_ fraction: CGFloat) -> PresentationDetent {
    PresentationDetent(storage: .fraction(fraction))
  }

  /// A detent for a sheet with a fixed height in points.
  public static func height(_ height: CGFloat) -> PresentationDetent {
    PresentationDetent(storage: .height(height))
  }
}

public extension View {
  /// Sets the available detents for the enclosing sheet.
  ///
  /// The sheet is presented at the smallest detent, anchored to the bottom of the
  /// screen over a dimmed scrim. Dragging between detents is not yet supported.
  /// Apply this modifier to the outermost view of the sheet's content.
  func presentationDetents(_ detents: Set<PresentationDetent>) -> some View {
    _PresentationDetentsView(anyContent: AnyView(self), detents: detents)
  }
}

/// Type-erased access to sheet content configured with presentation detents,
/// detected by the platform sheet container.
public protocol _AnyPresentationDetentsView {

  var detents: Set<PresentationDetent> { get }

  var anyContent: AnyView { get }
}

/// Marker wrapper produced by `presentationDetents(_:)`.
///
/// When the enclosing presentation container does not support detents, this view
/// renders its content unchanged.
public struct _PresentationDetentsView: View, _AnyPresentationDetentsView {

  public let anyContent: AnyView

  public let detents: Set<PresentationDetent>

  public var body: some View {
    anyContent
  }
}
