import AppIntents
import DawnWrist

/// The intents the Watch widgets use, from their packages.
struct DawnWatchWidgetIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [DawnWristIntents.self] }
}
