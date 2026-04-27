// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Analytics",
            targets: ["Analytics"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/PostHog/posthog-ios", from: "3.57.0"),
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "PostHog", package: "posthog-ios"),
            ],
            path: "Sources/Analytics"
        ),
    ]
)
