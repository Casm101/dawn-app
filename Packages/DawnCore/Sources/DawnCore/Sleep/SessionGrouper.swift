import Foundation

/// Turns raw sleep samples from any number of sources into nights and naps.
public enum SessionGrouper {
    public static func sessions(from samples: [SleepSample], calendar: Calendar) -> [SleepSession] {
        clusters(of: samples.sorted { $0.start < $1.start })
            .compactMap { session(from: $0, calendar: calendar) }
    }

    /// Splits time-ordered samples wherever nothing was recorded for `Tuning.Sleep.sessionGap` or longer.
    static func clusters(of sorted: [SleepSample]) -> [[SleepSample]] {
        var clusters: [[SleepSample]] = []
        var current: [SleepSample] = []
        var currentEnd = Date.distantPast
        for sample in sorted {
            if !current.isEmpty, sample.start.timeIntervalSince(currentEnd) >= Tuning.Sleep.sessionGap {
                clusters.append(current)
                current = []
            }
            currentEnd = current.isEmpty ? sample.end : max(currentEnd, sample.end)
            current.append(sample)
        }
        if !current.isEmpty { clusters.append(current) }
        return clusters
    }

    /// One source's samples from the cluster, flattened and trimmed to the asleep span.
    static func session(from cluster: [SleepSample], calendar: Calendar) -> SleepSession? {
        guard let source = DominantSource.pick(from: cluster) else { return nil }
        let timeline = SampleTimeline.flatten(cluster.filter { $0.source == source })
        guard let first = timeline.firstIndex(where: \.stage.isAsleep),
              let last = timeline.lastIndex(where: \.stage.isAsleep) else { return nil }
        let samples = Array(timeline[first...last])
        let kind = SleepKind(start: samples[0].start, end: samples[samples.count - 1].end, calendar: calendar)
        return SleepSession(kind: kind, source: source, samples: samples)
    }
}
