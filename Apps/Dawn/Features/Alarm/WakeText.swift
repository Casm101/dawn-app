import DawnCore
import Foundation

/// The words for a wake window's outcome.
enum WakeText {
    static func headline(_ outcome: WakeOutcome) -> String {
        let day = outcome.windowEnd.formatted(.dateTime.weekday(.wide).day().month())
        switch outcome.result {
        case .wokeEarly:
            let time = (outcome.firedAt ?? outcome.windowEnd).formatted(date: .omitted, time: .shortened)
            return String(localized: "wake.early", defaultValue: "\(day): woken at \(time) by your Watch")
        case .wokeAtEnd:
            return String(localized: "wake.end", defaultValue: "\(day): woken at the end of the window")
        case .sessionEnded:
            return String(localized: "wake.ended", defaultValue: "\(day): the Watch's window ended without waking you")
        }
    }

    static func detail(_ outcome: WakeOutcome) -> String {
        let reason = outcome.trigger.map(trigger) ?? String(localized: "wake.reason.none", defaultValue: "Nothing detected")
        switch (outcome.usedMotion, outcome.usedHeartRate) {
        case (true, true):
            return String(localized: "wake.detail.both", defaultValue: "\(reason), using motion and heart rate")
        case (true, false):
            return String(localized: "wake.detail.motion", defaultValue: "\(reason), using motion")
        case (false, true):
            return String(localized: "wake.detail.heart", defaultValue: "\(reason), using heart rate")
        case (false, false):
            return String(localized: "wake.detail.none", defaultValue: "\(reason), with no sensor readings")
        }
    }

    private static func trigger(_ trigger: WakeTrigger) -> String {
        switch trigger {
        case .stirring: String(localized: "wake.reason.stirring", defaultValue: "You were stirring")
        case .stirringWithHeartRate: String(localized: "wake.reason.stirringHeart", defaultValue: "You were stirring and your heart rate rose")
        case .strongBurst: String(localized: "wake.reason.burst", defaultValue: "You moved strongly")
        case .windowEnd: String(localized: "wake.reason.windowEnd", defaultValue: "The window ended")
        case .sessionExpiring: String(localized: "wake.reason.expiring", defaultValue: "The Watch's session was ending")
        }
    }
}
