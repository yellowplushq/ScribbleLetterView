// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScribbleLetterView",
    platforms: [
        .iOS(.v15),
        // Only the platform-independent layout core builds on macOS, so `swift test` runs on the host.
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "ScribbleLetter", targets: ["ScribbleLetter"]),
    ],
    targets: [
        .target(
            name: "ScribbleLetter",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ScribbleLetterTests",
            dependencies: ["ScribbleLetter"]
        ),
    ]
)
