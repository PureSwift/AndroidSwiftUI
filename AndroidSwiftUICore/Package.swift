// swift-tools-version: 6.1
import PackageDescription

// Platform-neutral SwiftUI evaluation core: evaluates view trees into a
// RenderNode tree the Compose interpreter consumes. No Android or JVM imports,
// so the whole package builds and tests on any host (macOS/Linux). Consumed by
// the AndroidSwiftUI package (and extractable for other backends, e.g. the
// ClassicUI-style desktop renderer it shares its design with).
let package = Package(
    name: "AndroidSwiftUICore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AndroidSwiftUICore", targets: ["AndroidSwiftUICore"])
    ],
    targets: [
        .target(name: "AndroidSwiftUICore"),
        .testTarget(
            name: "AndroidSwiftUICoreTests",
            dependencies: ["AndroidSwiftUICore"]
        )
    ]
)
