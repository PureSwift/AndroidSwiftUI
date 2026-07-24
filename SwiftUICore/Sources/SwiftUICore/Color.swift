//
//  Color.swift
//  SwiftUICore
//

/// An sRGB color with an opacity.
public struct Color: Equatable, Sendable {

    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red; self.green = green; self.blue = blue; self.opacity = opacity
    }

    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 0.8, blue: 0)
    public static let blue = Color(red: 0, green: 0.48, blue: 1)
    public static let orange = Color(red: 1, green: 0.58, blue: 0)
    public static let yellow = Color(red: 1, green: 0.8, blue: 0)
    public static let purple = Color(red: 0.69, green: 0.32, blue: 0.87)
    public static let pink = Color(red: 1, green: 0.18, blue: 0.33)
    public static let gray = Color(red: 0.56, green: 0.56, blue: 0.58)
    public static let clear = Color(red: 0, green: 0, blue: 0, opacity: 0)

    /// 0xAARRGGBB, the form Android's `setColor`/Compose `Color(argb)` expect.
    public var argb: Int64 {
        func channel(_ value: Double) -> Int64 { Int64((value * 255).rounded()) & 0xFF }
        return (channel(opacity) << 24) | (channel(red) << 16) | (channel(green) << 8) | channel(blue)
    }

    internal var propValue: PropValue { .int(Int(argb)) }
}
