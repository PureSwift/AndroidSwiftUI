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
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Android.git",
            branch: "master"
        ),
        .package(
          url: "https://github.com/PureSwift/OpenCombine.git",
          branch: "feature/android"
        )
    ],
    targets: [
        .target(
            name: "AndroidSwiftUI",
            dependencies: [
                .product(
                    name: "AndroidKit",
                    package: "Android"
                ),
                .product(
                    name: "OpenCombineShim",
                    package: "OpenCombine"
                )
            ],
            swiftSettings: [
              .swiftLanguageMode(.v5)
            ]
        )
    ]
)
