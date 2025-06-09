//
//  ModifiedContent.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

public protocol _AnyModifiedContent {
  var anyContent: AnyView { get }
  var anyModifier: AndroidViewModifier { get }
}

extension ModifiedContent: _AnyModifiedContent where Modifier: AndroidViewModifier, Content: View {
  public var anyContent: AnyView {
    AnyView(content)
  }

  public var anyModifier: AndroidViewModifier {
    modifier
  }
}

extension ModifiedContent: AndroidPrimitive where Content: View, Modifier: ViewModifier {

 public var renderedBody: AnyView {
    if let androidModifier = modifier as? AndroidViewModifier {
      if let adjacentModifier = content as? _AnyModifiedContent {
          
      } else {
          
      }
    } else if Modifier.Body.self == Never.self {
      return AnyView(content)
    } else {
      return AnyView(modifier.body(content: .init(modifier: modifier, view: AnyView(content))))
    }
  }
}
