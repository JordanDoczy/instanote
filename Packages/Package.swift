// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "instanote",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "CreateNoteFeature", targets: ["CreateNoteFeature"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "ListFeature", targets: ["ListFeature"]),
        .library(name: "SharedExtensions", targets: ["SharedExtensions"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "SharedViews", targets: ["SharedViews"]),
        .library(name: "Storage", targets: ["Storage"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.47.2"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", .upToNextMajor(from: "0.7.0")),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-overture", .upToNextMajor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "CreateNoteFeature",
            dependencies: [
                "SharedViews",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FileClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "FileClientTests",
            dependencies: [
                "FileClient"
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "ListFeature",
            dependencies: [
                "CreateNoteFeature",
                "FileClient",
                "SharedModels",
                "Storage",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "SharedExtensions",
            dependencies: []
        ),
        .target(
            name: "SharedModels",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged")
            ]
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"]
        ),
        .target(
            name: "SharedViews",
            dependencies: []
        ),
        .target(
            name: "Storage",
            dependencies: [
                "SharedExtensions",
                "SharedModels",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: [
                "Storage",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Overture", package: "swift-overture"),
            ]
        ),
    ]
)
