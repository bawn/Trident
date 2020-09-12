// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Trident",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Trident",
            targets: ["Trident"]),
    ],
    targets: [
        .target(
            name: "Trident",
            path: "Trident")
    ]
)
