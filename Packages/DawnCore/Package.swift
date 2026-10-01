// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnCore",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnCore", targets: ["DawnCore"])],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DawnCore",
            dependencies: [],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(name: "DawnCoreTests", dependencies: ["DawnCore"]),
    ],
    swiftLanguageModes: [.v6]
)
