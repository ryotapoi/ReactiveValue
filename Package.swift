// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveValue",
    platforms: [
        .macOS(.v11),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReactiveValue",
            targets: ["ReactiveValue"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ReactiveValue"),
        .testTarget(
            name: "ReactiveValueTests",
            dependencies: ["ReactiveValue"]),
    ]
)
