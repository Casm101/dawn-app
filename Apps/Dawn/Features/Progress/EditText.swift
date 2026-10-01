import DawnCore
import DawnUI
import Foundation

/// The words for correcting nights and adding naps.
enum EditText {
    static func problem(_ problem: NightEditProblem) -> String {
        let shortest = DurationFormat.short(Tuning.Edits.shortestStretch)
        switch problem {
        case .tooShort:
            return String(localized: "edit.problem.tooShort", defaultValue: "Each stretch of sleep needs at least \(shortest), so that change was undone.")
        case .tooOld:
            return String(localized: "edit.problem.tooOld", defaultValue: "Only the last two weeks can be changed.")
        case .overlaps:
            return String(localized: "edit.problem.overlaps", defaultValue: "That overlaps sleep already recorded, so it would count twice.")
        }
    }

    static var hint: String {
        let step = DurationFormat.short(Tuning.Edits.step), gap = DurationFormat.short(Tuning.Edits.insertedGap)
        return String(
            localized: "edit.hint",
            defaultValue: "Drag either end of a stretch to move it in \(step) steps. Press and hold a stretch to add \(gap) awake there. Swipe a stretch below to delete it."
        )
    }

    static func total(_ edit: NightEdit) -> String {
        let asleep = edit.segments.reduce(0) { $0 + $1.duration }
        return String(localized: "edit.total", defaultValue: "Asleep \(DurationFormat.short(asleep))")
    }

    static func stretch(_ segment: DateInterval) -> String {
        String(localized: "edit.stretch", defaultValue: "\(NightText.range(segment.start, segment.end)), \(DurationFormat.short(segment.duration))")
    }

    static var insertGap: String {
        String(localized: "edit.insertGap", defaultValue: "Add awake time here")
    }

    static func handle(_ edge: NightEdge, at moment: Date) -> String {
        let time = moment.formatted(date: .omitted, time: .shortened)
        switch edge {
        case .start: return String(localized: "edit.handle.start", defaultValue: "Fell asleep at \(time)")
        case .end: return String(localized: "edit.handle.end", defaultValue: "Woke at \(time)")
        }
    }

    static var edited: String { String(localized: "edit.edited", defaultValue: "Edited") }
    static var reset: String { String(localized: "edit.reset", defaultValue: "Use Apple Health's times") }
    static var delete: String { String(localized: "edit.delete", defaultValue: "Delete") }
    static var editTitle: String { String(localized: "edit.title", defaultValue: "Correct this night") }
}
