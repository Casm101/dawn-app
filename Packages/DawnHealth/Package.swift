// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnHealth",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnHealth", targets: ["DawnHealth"])],
    dependencies: [
        .package(path: "../DawnCore"),
    ],
    targets: [
        .target(
            name: "DawnHealth",
            dependencies: ["DawnCore"],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(name: "DawnHealthTests", dependencies: ["DawnHealth"]),
    ],
    swiftLanguageModes: [.v6]
)
