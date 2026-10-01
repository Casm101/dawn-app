// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnAlarmKit",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnAlarmKit", targets: ["DawnAlarmKit"])],
    dependencies: [
        .package(path: "../DawnCore"),
    ],
    targets: [
        .target(
            name: "DawnAlarmKit",
            dependencies: ["DawnCore"],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(name: "DawnAlarmKitTests", dependencies: ["DawnAlarmKit"]),
    ],
    swiftLanguageModes: [.v6]
)
