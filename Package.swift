// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]),
    ],
    dependencies: [
        // Fork of VideoFlint/Cabbage. Upstream has been dormant since March 2022 and the
        // published 0.5.1 lacks AVURLAssetTrackResource and the VideoCompositor thread-safety
        // fixes that Classes/Utilities/VideoFramework depends on.
        .package(url: "https://github.com/joeypatino/Cabbage.git", from: "0.5.2")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "VFCabbage", package: "Cabbage")
            ],
            path: "Core",
            exclude: ["Scripts"],
            sources: ["Classes"],
            resources: [
                .process("Localizable.strings")
            ]
        )
    ]
)
