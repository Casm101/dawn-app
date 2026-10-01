// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DawnUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],
    products: [.library(name: "DawnUI", targets: ["DawnUI"])],
    dependencies: [
        .package(path: "../DawnCore"),
    ],
    targets: [
        .target(
            name: "DawnUI",
            dependencies: ["DawnCore"],
            resources: [.process("Resources")],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility"), .defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "DawnUITests", dependencies: ["DawnUI"]),
    ],
    swiftLanguageModes: [.v6]
)
