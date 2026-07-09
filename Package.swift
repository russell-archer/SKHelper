// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift 6.1 requires Xcode 16.3.

import PackageDescription

let package = Package(
    name: "SKHelper",
    platforms: [.iOS("17.0"), .macOS("14.6")],
    products: [
        .library(name: "SKHelperCore", targets: ["SKHelperCore"]),
        .library(name: "SKHelperUI", targets: ["SKHelperUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "SKHelperCore",
            resources: [.process("Resources")]
        ),
        .target(
            name: "SKHelperUI",
            dependencies: ["SKHelperCore"]
        ),
    ]
)
