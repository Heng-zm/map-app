// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapViewer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MapViewerCore",
            targets: ["MapViewerCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MapViewerCore",
            dependencies: [],
            path: "MapViewer",
            exclude: [
                "Resources/Info.plist",
                "Resources/MapViewer.entitlements",
                "Resources/Assets.xcassets"
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "MapViewerTests",
            dependencies: ["MapViewerCore"],
            path: "MapViewerTests",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
