// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "SwiftRichString",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SwiftRichString",
            type: .static,
            targets: ["SwiftRichString"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftRichString",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftRichStringTests",
            dependencies: ["SwiftRichString"]
        ),
    ]
)
