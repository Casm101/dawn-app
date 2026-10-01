import Foundation

/// A night's stretches of sleep being corrected: edges moved in `Tuning.Edits.step` steps, awake
/// gaps inserted, stretches deleted. Every edit that would leave a stretch shorter than
/// `Tuning.Edits.shortestStretch` is refused and changes nothing.
public struct NightEdit: Hashable, Sendable {
    private typealias T = Tuning.Edits

    /// The stretches of sleep, in order, never overlapping.
    public private(set) var segments: [DateInterval]

    public init(segments: [DateInterval]) {
        self.segments = segments.sorted { $0.start < $1.start }
    }

    /// The moment snapped to the nearest step.
    public static func snap(_ date: Date) -> Date {
        Date(timeIntervalSinceReferenceDate: (date.timeIntervalSinceReferenceDate / T.step).rounded() * T.step)
    }

    /// Moves one end of a stretch to `date`, snapped, and kept a step clear of its neighbours.
    @discardableResult
    public mutating func move(_ index: Int, _ edge: NightEdge, to date: Date) -> NightEditProblem? {
        guard segments.indices.contains(index) else { return nil }
        let segment = segments[index]
        var moved = Self.snap(date)
        switch edge {
        case .start:
            if index > 0 { moved = max(moved, segments[index - 1].end.addingTimeInterval(T.step)) }
            guard segment.end.timeIntervalSince(moved) >= T.shortestStretch else { return .tooShort }
            segments[index] = DateInterval(start: moved, end: segment.end)
        case .end:
            if index + 1 < segments.count { moved = min(moved, segments[index + 1].start.addingTimeInterval(-T.step)) }
            guard moved.timeIntervalSince(segment.start) >= T.shortestStretch else { return .tooShort }
            segments[index] = DateInterval(start: segment.start, end: moved)
        }
        return nil
    }

    /// Splits the stretch holding `date` with a `Tuning.Edits.insertedGap` awake gap starting there.
    @discardableResult
    public mutating func insertGap(at date: Date) -> NightEditProblem? {
        let at = Self.snap(date)
        guard let index = segments.firstIndex(where: { $0.start < at && at < $0.end }) else { return nil }
        let segment = segments[index]
        let resume = at.addingTimeInterval(T.insertedGap)
        guard at.timeIntervalSince(segment.start) >= T.shortestStretch,
              segment.end.timeIntervalSince(resume) >= T.shortestStretch else { return .tooShort }
        segments.replaceSubrange(index...index, with: [
            DateInterval(start: segment.start, end: at), DateInterval(start: resume, end: segment.end),
        ])
        return nil
    }

    /// Deletes a stretch. The last one stays, so the night can still be opened and reset.
    @discardableResult
    public mutating func delete(_ index: Int) -> NightEditProblem? {
        guard segments.indices.contains(index) else { return nil }
        guard segments.count > 1 else { return .lastStretch }
        segments.remove(at: index)
        return nil
    }

    /// The span the editing track shows: the night with room either side to move its edges.
    public var track: DateInterval? {
        guard let first = segments.first, let last = segments.last else { return nil }
        return DateInterval(start: first.start.addingTimeInterval(-T.trackMargin), end: last.end.addingTimeInterval(T.trackMargin))
    }
}
