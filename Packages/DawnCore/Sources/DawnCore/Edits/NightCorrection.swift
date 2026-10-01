import Foundation

/// A corrected night: the stretches of sleep the user settled on for one evening. It stands in for
/// whatever Health holds for that evening, now and after every later import.
public struct NightCorrection: Hashable, Sendable, Codable {
    /// The evening's day, as Progress groups nights.
    public let day: CalendarDay
    public let segments: [DateInterval]

    public init(day: CalendarDay, segments: [DateInterval]) {
        self.day = day
        self.segments = segments.sorted { $0.start < $1.start }
    }

    /// The night these stretches make from Health's own sessions for the evening: Health's stages
    /// where they overlap, unstaged sleep where the user added time, and awake between stretches.
    /// Nil when there are no stretches.
    public func session(from imported: [SleepSession]) -> SleepSession? {
        guard !segments.isEmpty else { return nil }
        let source = imported.max { $0.asleep < $1.asleep }?.source ?? Tuning.Edits.source
        let asleep = imported.flatMap(\.samples).filter(\.stage.isAsleep).sorted { $0.start < $1.start }
        var samples: [SleepSample] = []
        for (index, segment) in segments.enumerated() {
            if index > 0 {
                samples.append(SleepSample(start: segments[index - 1].end, end: segment.start, stage: .awake, source: Tuning.Edits.source))
            }
            var cursor = segment.start
            for sample in asleep where sample.end > segment.start && sample.start < segment.end {
                let start = max(sample.start, cursor), end = min(sample.end, segment.end)
                guard start < end else { continue }
                if start > cursor { samples.append(SleepSample(start: cursor, end: start, stage: .unspecified, source: Tuning.Edits.source)) }
                samples.append(SleepSample(start: start, end: end, stage: sample.stage, source: sample.source))
                cursor = end
            }
            if cursor < segment.end {
                samples.append(SleepSample(start: cursor, end: segment.end, stage: .unspecified, source: Tuning.Edits.source))
            }
        }
        return SleepSession(kind: .night, source: source, samples: samples)
    }
}
