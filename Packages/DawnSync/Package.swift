// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnSync",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnSync", targets: ["DawnSync"])],
    dependencies: [
        .package(path: "../DawnCore"),
    ],
    targets: [
        .target(
            name: "DawnSync",
            dependencies: ["DawnCore"],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(name: "DawnSyncTests", dependencies: ["DawnSync"]),
    ],
    swiftLanguageModes: [.v6]
)
