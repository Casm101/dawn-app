import DawnCore
import DawnUI
import Foundation

/// The words for correcting nights and adding naps.
enum EditText {
    /// Why a change was undone or a nap was not added.
    static func problem(_ problem: NightEditProblem) -> String {
        switch problem {
        case .tooShort:
            return String(
                localized: "edit.problem.tooShort",
                defaultValue: "Each stretch of sleep needs at least \(DurationFormat.short(Tuning.Edits.shortestStretch)), so that change was undone."
            )
        case .tooOld:
            return String(localized: "edit.problem.tooOld", defaultValue: "Only the last \(Tuning.Edits.days) days can be changed.")
        case .overlaps:
            return String(localized: "edit.problem.overlaps", defaultValue: "That overlaps sleep already recorded, so it would count twice.")
        case .endsBeforeStart:
            return String(localized: "nap.problem.endsBeforeStart", defaultValue: "A nap has to end after it starts.")
        case .inFuture:
            return String(localized: "nap.problem.inFuture", defaultValue: "That nap has not ended yet.")
        case .lastStretch:
            return String(localized: "edit.problem.lastStretch", defaultValue: "A night keeps at least one stretch of sleep.")
        }
    }

    /// The same, worded for a nap.
    static func napProblem(_ problem: NightEditProblem) -> String {
        guard problem == .tooShort else { return self.problem(problem) }
        return String(localized: "nap.problem.tooShort", defaultValue: "A nap needs at least \(DurationFormat.short(Tuning.Edits.shortestStretch)).")
    }

    static var notSaved: String {
        String(localized: "edit.notSaved", defaultValue: "Dawn could not save your changes on this iPhone, so they last until Dawn closes.")
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
