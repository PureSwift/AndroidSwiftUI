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
        // The umbrella app code imports: the SwiftUI API and Compose bridge,
        // re-exported, plus the Android host (android.view bridging).
        .library(
            name: "AndroidSwiftUI",
            targets: ["AndroidSwiftUI"]
        ),
        // The platform-neutral JNI bridge to the Compose interpreter, on its own.
        .library(
            name: "ComposeUI",
            targets: ["ComposeUI"]
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
        // A Swift global actor backed by the Android main looper, so `@MainActor`
        // / `DispatchQueue.main` work on Android without hand-draining a RunLoop.
        // Same identity (`swift-android-native`) as the PureSwift/Android
        // dependency; pinned to the fork/branch that package uses so the Android
        // build's single-revision requirement is satisfied.
        .package(
            url: "https://github.com/MillerTechnologyPeru/swift-android-native.git",
            branch: "feature/pureswift"
        ),
        .package(path: "SwiftUICore")
    ],
    targets: [
        // The Android umbrella: re-exports SwiftUICore + ComposeUI and adds the
        // android.view bridging (MainActivity, Application, host view).
        .target(
            name: "AndroidSwiftUI",
            dependencies: [
                "ComposeUI",
                .product(
                    name: "SwiftUICore",
                    package: "SwiftUICore"
                ),
                .product(
                    name: "AndroidKit",
                    package: "Android"
                ),
                .product(
                    name: "AndroidLooper",
                    package: "swift-android-native",
                    condition: .when(platforms: [.android])
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
            name: "ComposeUI",
            dependencies: [
                .product(name: "SwiftUICore", package: "SwiftUICore"),
                .product(name: "SwiftJava", package: "swift-java")
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "SwiftUIDesktopDemo",
            dependencies: [
                "ComposeUI",
                .product(name: "SwiftUICore", package: "SwiftUICore")
            ],
            // `Playgrounds` symlinks the Android demo's shared sources; the rig
            // reuses them verbatim on desktop. Excluded: the app entry point (it
            // needs the Android host or Apple's App/Scene), and the three
            // Android-only screens — Map (schematic), Video (Media3), and Custom
            // Views (the native-view composable registry) — which have no desktop
            // rendering. Their catalog entries are `#if canImport(AndroidSwiftUI)`.
            exclude: [
                "Playgrounds/App.swift",
                "Playgrounds/MapPlaygrounds.swift",
                "Playgrounds/VideoPlaygrounds.swift",
                "Playgrounds/RepresentablePlaygrounds.swift",
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        )
    ]
)
