import DawnCore
import Foundation

/// The words for the day's phases and how they moved.
enum PhaseText {
    static func name(_ phase: EnergyPhase) -> String {
        switch phase {
        case .grogginess: String(localized: "phase.grogginess", defaultValue: "Grogginess")
        case .morningPeak: String(localized: "phase.morningPeak", defaultValue: "Morning peak")
        case .afternoonDip: String(localized: "phase.afternoonDip", defaultValue: "Afternoon dip")
        case .eveningPeak: String(localized: "phase.eveningPeak", defaultValue: "Evening peak")
        case .windDown: String(localized: "phase.windDown", defaultValue: "Wind-down")
        case .melatoninWindow: String(localized: "phase.melatoninWindow", defaultValue: "Melatonin window")
        }
    }

    static func change(_ change: PhaseChange) -> String {
        switch change {
        case .same: String(localized: "phase.change.same", defaultValue: "Same as yesterday")
        case .later(let minutes): String(localized: "phase.change.later", defaultValue: "\(minutes) min later than yesterday")
        case .earlier(let minutes): String(localized: "phase.change.earlier", defaultValue: "\(minutes) min earlier than yesterday")
        }
    }

    static func span(_ span: PhaseSpan) -> String {
        String(localized: "phase.span", defaultValue: "\(time(span.start)) – \(time(span.end))")
    }

    static func until(_ span: PhaseSpan) -> String {
        String(localized: "phase.until", defaultValue: "until \(time(span.end))")
    }

    static var learning: String {
        String(localized: "phase.learning", defaultValue: "Learning")
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
