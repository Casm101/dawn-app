import Foundation

/// The three views the Progress tab switches between.
enum ProgressSegment: Hashable, CaseIterable {
    case sleepTimes
    case sleepDebt
    case sleepQuality

    var title: String {
        switch self {
        case .sleepTimes: String(localized: "progress.segment.times", defaultValue: "Sleep Times")
        case .sleepDebt: String(localized: "progress.segment.debt", defaultValue: "Sleep Debt")
        case .sleepQuality: String(localized: "progress.segment.quality", defaultValue: "Sleep Quality")
        }
    }
}
