// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnWrist",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnWrist", targets: ["DawnWrist"])],
    dependencies: [
        .package(path: "../DawnCore"),
    ],
    targets: [
        .target(
            name: "DawnWrist",
            dependencies: ["DawnCore"],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(name: "DawnWristTests", dependencies: ["DawnWrist"]),
    ],
    swiftLanguageModes: [.v6]
)
