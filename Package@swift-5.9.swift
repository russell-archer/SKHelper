// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift 5.9 requires Xcode 15.

import PackageDescription

let package = Package(
    name: "SKHelper",
    platforms: [.iOS("16.4"), .macOS("14.6"), ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SKHelper", targets: ["SKHelper"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SKHelper"),
        .testTarget(
            name: "SKHelperTests",
            dependencies: ["SKHelper"]
        ),
    ]
)
