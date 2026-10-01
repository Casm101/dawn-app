import Foundation

extension NightSlot {
    /// Segments and awake stretches in time order, including the awake time between two sessions
    /// that began on the same evening.
    public var timeline: [NightTimelineEntry] {
        let asleep = segments.map { NightTimelineEntry(start: $0.start, end: $0.end, isAwake: false) }
        let sorted = asleep.sorted { $0.start < $1.start }
        let awake = zip(sorted, sorted.dropFirst()).compactMap { before, after in
            after.start > before.end ? NightTimelineEntry(start: before.end, end: after.start, isAwake: true) : nil
        }
        return (sorted + awake).sorted { $0.start < $1.start }
    }

    /// Stage totals across every session of the evening, or nil when none of them carries stages.
    /// Unstaged sleep from a session without stages counts as unspecified.
    public var stageTotals: StageTotals? {
        guard nights.contains(where: { $0.stageTotals != nil }) else { return nil }
        let awake = timeline.filter(\.isAwake).reduce(0) { $0 + $1.duration }
        var rem = 0.0, core = 0.0, deep = 0.0, unspecified = 0.0
        for night in nights {
            if let totals = night.stageTotals {
                rem += totals.rem
                core += totals.core
                deep += totals.deep
                unspecified += totals.unspecified
            } else {
                unspecified += night.asleep
            }
        }
        return StageTotals(awake: awake, rem: rem, core: core, deep: deep, unspecified: unspecified)
    }
}
