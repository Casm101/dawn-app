import Foundation

extension SleepSession {
    /// The asleep stretches of the session, in order. Asleep samples that touch join one segment.
    public var segments: [SleepSegment] {
        var segments: [SleepSegment] = []
        var current: [SleepSample] = []
        for sample in samples {
            if sample.stage.isAsleep, current.last.map({ $0.end >= sample.start }) ?? true {
                current.append(sample)
                continue
            }
            if !current.isEmpty { segments.append(segment(current)) }
            current = sample.stage.isAsleep ? [sample] : []
        }
        if !current.isEmpty { segments.append(segment(current)) }
        return segments
    }

    /// The awake time between consecutive segments.
    public var awakeGaps: [DateInterval] {
        zip(segments, segments.dropFirst()).map { DateInterval(start: $0.end, end: $1.start) }
    }

    private func segment(_ samples: [SleepSample]) -> SleepSegment {
        SleepSegment(start: samples[0].start, end: samples[samples.count - 1].end, samples: samples)
    }
}
