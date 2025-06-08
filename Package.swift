// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AndroidSwiftUI",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AndroidSwiftUI",
            targets: ["AndroidSwiftUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Android.git",
            branch: "feature/javakit"
        )
    ],
    targets: [
        .target(
            name: "AndroidSwiftUI",
            dependencies: [
                .product(
                    name: "AndroidKit",
                    package: "Android"
                )
            ]
        )
    ]
)
