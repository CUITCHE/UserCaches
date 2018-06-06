// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserCaches",
    products: [
        .library(
            name: "UserCaches",
            targets: ["UserCaches"]),
        ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.11.5")
    ],
    targets: [
        .target(
            name: "UserCaches",
            dependencies: ["SQLite"]),
        .testTarget(
            name: "UserCachesTests",
            dependencies: ["UserCaches"]),
        ]
)

