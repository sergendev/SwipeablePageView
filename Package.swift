// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwipeableContainer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwipeableContainer",
            targets: ["SwipeableContainer"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwipeableContainer"),
        .testTarget(
            name: "SwipeableContainerTests",
            dependencies: ["SwipeableContainer"]
        ),
    ]
)
