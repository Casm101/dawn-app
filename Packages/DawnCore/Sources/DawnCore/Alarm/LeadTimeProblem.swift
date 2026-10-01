import Foundation

/// Why an alarm saved now may not ring when the user expects, given the system's minimum notice.
public enum LeadTimeProblem: Hashable, Sendable {
    /// A repeating alarm whose next ring is too close; from `following` it rings as set.
    case nextRingTooClose(skipped: Date, following: Date)
    /// A one-off alarm whose only ring is too close to rely on, so it should not be saved as is.
    case tooCloseToSet
}
