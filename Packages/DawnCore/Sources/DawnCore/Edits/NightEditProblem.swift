/// Why an edit to a night was refused and left the night as it was.
public enum NightEditProblem: Hashable, Sendable {
    /// It would leave a stretch of sleep, or a nap, shorter than `Tuning.Edits.shortestStretch`.
    case tooShort
    /// The day is further back than `Tuning.Edits.days`.
    case tooOld
    /// A nap would overlap sleep already recorded, and count twice.
    case overlaps
}
