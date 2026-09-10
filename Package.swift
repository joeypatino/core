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
        .library(
            name: "CoreVideoKit",
            targets: ["CoreVideoKit"]),
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
            dependencies: [],
            path: "Core",
            exclude: ["Scripts", "VideoClasses"],
            sources: ["Classes"],
            resources: [
                .process("Localizable.strings")
            ]
        ),
        .target(
            name: "CoreVideoKit",
            dependencies: [
                "Core",
                .product(name: "VFCabbage", package: "Cabbage")
            ],
            path: "Core/VideoClasses"
        )
    ]
)
