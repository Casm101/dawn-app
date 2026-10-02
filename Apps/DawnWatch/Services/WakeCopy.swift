import DawnCore
import Foundation

/// The Watch's words for the wake window.
enum WakeCopy {
    static var nudgeTitle: String {
        String(localized: "watch.nudge.title", defaultValue: "Arm tonight's wake window")
    }

    static var nudgeBody: String {
        String(localized: "watch.nudge.body", defaultValue: "Open Dawn so your Watch can wake you at a lighter moment.")
    }

    static var armed: String { String(localized: "watch.armed", defaultValue: "Armed") }

    static var nothingToArm: String { String(localized: "watch.nothingToArm", defaultValue: "Nothing to arm") }

    static var notArmed: String { String(localized: "watch.notArmed", defaultValue: "Not armed") }

    static var openToArm: String {
        String(localized: "watch.openToArm", defaultValue: "Open Dawn to arm it; your iPhone alarm still rings.")
    }

    static var armFailed: String {
        String(localized: "watch.armFailed", defaultValue: "The Watch could not arm it. Open Dawn again; your iPhone alarm still rings.")
    }

    static func window(_ plan: WakePlan) -> String {
        let start = plan.windowStart.formatted(date: .omitted, time: .shortened)
        let end = plan.windowEnd.formatted(date: .omitted, time: .shortened)
        return String(localized: "watch.window", defaultValue: "\(start) – \(end)")
    }

    static func last(_ outcome: WakeOutcome) -> String {
        let time = (outcome.firedAt ?? outcome.windowEnd).formatted(date: .omitted, time: .shortened)
        switch outcome.result {
        case .wokeEarly: return String(localized: "watch.last.early", defaultValue: "Last woke you at \(time)")
        case .wokeAtEnd: return String(localized: "watch.last.end", defaultValue: "Last woke you at \(time), the window's end")
        case .sessionEnded: return String(localized: "watch.last.ended", defaultValue: "Last window ended without waking you")
        }
    }

    /// Why the last window fired and which sensors it had, as the phone's history says.
    static func why(_ outcome: WakeOutcome) -> String {
        let reason = switch outcome.trigger {
        case .stirring?, .stirringWithHeartRate?: String(localized: "watch.reason.stirring", defaultValue: "You were stirring")
        case .strongBurst?: String(localized: "watch.reason.burst", defaultValue: "You moved strongly")
        case .windowEnd?: String(localized: "watch.reason.windowEnd", defaultValue: "The window ended")
        case .sessionExpiring?: String(localized: "watch.reason.expiring", defaultValue: "The session was ending")
        case nil: String(localized: "watch.reason.none", defaultValue: "Nothing detected")
        }
        let sensors = switch (outcome.usedMotion, outcome.usedHeartRate) {
        case (true, true): String(localized: "watch.sensors.both", defaultValue: "motion and heart rate")
        case (true, false): String(localized: "watch.sensors.motion", defaultValue: "motion")
        case (false, true): String(localized: "watch.sensors.heart", defaultValue: "heart rate")
        case (false, false): String(localized: "watch.sensors.none", defaultValue: "no sensors")
        }
        return String(localized: "watch.why", defaultValue: "\(reason), using \(sensors)")
    }
}
