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

import struct Foundation.CGFloat

public struct UIColor {
  let color: Color

  public static let clear: Self = .init(color: .clear)
  public static let black: Self = .init(color: .black)
  public static let white: Self = .init(color: .white)
  public static let gray: Self = .init(color: .gray)
  public static let red: Self = .init(color: .red)
  public static let green: Self = .init(color: .green)
  public static let blue: Self = .init(color: .blue)
  public static let orange: Self = .init(color: .orange)
  public static let yellow: Self = .init(color: .yellow)
  public static let pink: Self = .init(color: .pink)
  public static let purple: Self = .init(color: .purple)
}

public extension UIColor {
    
    /// Returns the components that form the color in the RGB color space.
    func getRed(
        _ red: inout CGFloat,
        green: inout CGFloat,
        blue: inout CGFloat,
        alpha: inout CGFloat
    ) -> Bool {
        return color.getRed(&red, green: &green, blue: &blue, alpha: &alpha, in: .defaultEnvironment)
    }
}

internal extension Color {
    
    /// Returns the components that form the color in the RGB color space.
    func getRed(
        _ red: inout CGFloat,
        green: inout CGFloat,
        blue: inout CGFloat,
        alpha: inout CGFloat,
        in environment: EnvironmentValues
    ) -> Bool {
        let rgba = provider.resolve(in: environment)
        red = rgba.red
        green = rgba.green
        blue = rgba.blue
        alpha = rgba.opacity
        return rgba.space == .sRGB
    }
}
