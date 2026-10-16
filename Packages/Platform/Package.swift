// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Platform",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Platform",
            targets: ["Platform"]
        )
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Platform",
            dependencies: [
                .product(
                    name: "Domain",
                    package: "Domain"
                )
            ]
        ),
        .testTarget(
            name: "PlatformTests",
            dependencies: ["Platform"]
        )
    ]
)
