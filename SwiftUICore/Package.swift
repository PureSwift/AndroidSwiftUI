// swift-tools-version: 6.1
import PackageDescription

// Platform-neutral SwiftUI evaluation core: evaluates view trees into a
// RenderNode tree the Compose interpreter consumes. No Android or JVM imports,
// so the whole package builds and tests on any host (macOS/Linux). Consumed by
// ComposeUI (the JNI bridge) and the AndroidSwiftUI umbrella, and extractable
// for other backends (e.g. the ClassicUI-style desktop renderer it shares its
// design with).
let package = Package(
    name: "SwiftUICore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SwiftUICore", targets: ["SwiftUICore"])
    ],
    targets: [
        .target(name: "SwiftUICore"),
        .testTarget(
            name: "SwiftUICoreTests",
            dependencies: ["SwiftUICore"]
        )
    ]
)
