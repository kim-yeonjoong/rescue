// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Rescue",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "Rescue", targets: ["Rescue"]),
        .library(name: "RescueCore", targets: ["RescueCore"]),
    ],
    targets: [
        .target(
            name: "RescueCore"
        ),
        .executableTarget(
            name: "Rescue",
            dependencies: ["RescueCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RescueCoreTests",
            dependencies: ["RescueCore"]
        ),
        .testTarget(
            name: "RescueTests",
            dependencies: ["Rescue"]
        ),
    ]
)
