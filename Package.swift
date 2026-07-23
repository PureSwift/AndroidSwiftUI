// swift-tools-version: 6.1
import PackageDescription

import class Foundation.FileManager
import class Foundation.ProcessInfo

let package = Package(
    name: "AndroidSwiftUI",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AndroidSwiftUI",
            targets: ["AndroidSwiftUI"]
        ),
        .library(
            name: "AndroidSwiftUIBridge",
            targets: ["AndroidSwiftUIBridge"]
        ),
        // Desktop test-rig dylib: the bridge plus a demo root view, loaded by
        // the Compose Desktop rig on the host JVM.
        .library(
            name: "SwiftUIDesktopDemo",
            type: .dynamic,
            targets: ["SwiftUIDesktopDemo"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Android.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-java.git",
            branch: "main"
        ),
        .package(path: "AndroidSwiftUICore")
    ],
    targets: [
        .target(
            name: "AndroidSwiftUI",
            dependencies: [
                "AndroidSwiftUIBridge",
                .product(
                    name: "AndroidSwiftUICore",
                    package: "AndroidSwiftUICore"
                ),
                .product(
                    name: "AndroidKit",
                    package: "Android"
                )
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        ),
        // JNI bridge between the evaluation core and the Compose interpreter.
        // Platform-neutral: no android.* imports, so it builds for the desktop
        // JVM (macOS dylib) and cross-compiles for Android identically.
        .target(
            name: "AndroidSwiftUIBridge",
            dependencies: [
                .product(name: "AndroidSwiftUICore", package: "AndroidSwiftUICore"),
                .product(name: "SwiftJava", package: "swift-java")
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SwiftUIDesktopDemo",
            dependencies: [
                "AndroidSwiftUIBridge",
                .product(name: "AndroidSwiftUICore", package: "AndroidSwiftUICore")
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        )
    ]
)
