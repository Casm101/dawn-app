/// Removes overlaps from one source's samples: each sample starts no earlier than the one before ends.
enum SampleTimeline {
    static func flatten(_ samples: [SleepSample]) -> [SleepSample] {
        let sorted = samples.sorted { ($0.start, $0.end) < ($1.start, $1.end) }
        var flattened: [SleepSample] = []
        for sample in sorted {
            let start = max(sample.start, flattened.last?.end ?? sample.start)
            guard start < sample.end else { continue }
            flattened.append(SleepSample(start: start, end: sample.end, stage: sample.stage, source: sample.source))
        }
        return flattened
    }
}
