import DawnCore
import Foundation

/// The words and symbols for each habit.
nonisolated enum HabitText {
    static func name(_ habit: Habit) -> String {
        switch habit {
        case .morningLight: String(localized: "habit.morningLight", defaultValue: "Morning light")
        case .caffeineCutoff: String(localized: "habit.caffeineCutoff", defaultValue: "Caffeine cutoff")
        case .dimLights: String(localized: "habit.dimLights", defaultValue: "Dim the lights")
        case .windDown: String(localized: "habit.windDown", defaultValue: "Wind down")
        case .melatonin: String(localized: "habit.melatonin", defaultValue: "Melatonin")
        case .rateLastNight: String(localized: "habit.rateLastNight", defaultValue: "Rate last night")
        }
    }

    /// The line under a reminder's name.
    static func reminder(_ habit: Habit) -> String {
        switch habit {
        case .morningLight: String(localized: "habit.reminder.morningLight", defaultValue: "Get some daylight in the next hour.")
        case .caffeineCutoff: String(localized: "habit.reminder.caffeineCutoff", defaultValue: "Last caffeine of the day, so it has worn off by bedtime.")
        case .dimLights: String(localized: "habit.reminder.dimLights", defaultValue: "Dim the lights so melatonin can rise.")
        case .windDown: String(localized: "habit.reminder.windDown", defaultValue: "Time to start winding down for bed.")
        case .melatonin: String(localized: "habit.reminder.melatonin", defaultValue: "Time for your melatonin supplement.")
        case .rateLastNight: String(localized: "habit.reminder.rateLastNight", defaultValue: "How did you sleep? Tap to rate last night.")
        }
    }

    static func symbol(_ habit: Habit) -> String {
        switch habit {
        case .morningLight: "sun.max"
        case .caffeineCutoff: "cup.and.saucer"
        case .dimLights: "lightbulb.min"
        case .windDown: "moon"
        case .melatonin: "pills"
        case .rateLastNight: "star"
        }
    }

    /// The rating chip once last night has a score.
    static func rated(_ score: Int) -> String {
        String(localized: "habit.rated", defaultValue: "Last night \(score)/\(NightRating.scale.upperBound)")
    }

    /// A habit's time, or its span for morning light, such as "07:00 – 08:00".
    static func time(_ time: HabitTime) -> String {
        let start = time.start.formatted(date: .omitted, time: .shortened)
        guard let end = time.end else { return start }
        return String(localized: "habit.span", defaultValue: "\(start) – \(end.formatted(date: .omitted, time: .shortened))")
    }
}
