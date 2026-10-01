import AppIntents
import DawnWrist

/// The intents the Watch app uses, from its packages.
struct DawnWatchIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [DawnWristIntents.self] }
}
