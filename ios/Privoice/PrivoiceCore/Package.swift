// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PrivoiceCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "PrivoiceCore", targets: ["PrivoiceCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
    ],
    targets: [
        .target(
            name: "PrivoiceCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "PrivoiceCoreTests",
            dependencies: ["PrivoiceCore"]
        ),
    ]
)
