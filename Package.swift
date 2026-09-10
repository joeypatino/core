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
        // Fork of VideoFlint/Cabbage. Upstream has been dormant since March 2022; its
        // published 0.5.1 lacks AVURLAssetTrackResource and the outputDirectory parameter
        // that Classes/Utilities/VideoFramework uses, and does not compile against current SDKs.
        .package(url: "https://github.com/joeypatino/Cabbage.git", from: "0.5.3")
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
