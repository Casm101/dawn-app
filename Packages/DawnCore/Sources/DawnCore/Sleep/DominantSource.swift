/// Picks one source when several recorded the same session, so overlapping records are never added
/// together. A source with stages wins, then the one with the most time asleep.
enum DominantSource {
    static func pick(from samples: [SleepSample]) -> String? {
        let bySource = Dictionary(grouping: samples, by: \.source)
        return bySource
            .map { source, samples in
                (source: source,
                 staged: samples.contains(where: \.stage.isStaged),
                 asleep: samples.filter(\.stage.isAsleep).reduce(0) { $0 + $1.duration })
            }
            .filter { $0.asleep > 0 }
            .max { lhs, rhs in
                if lhs.staged != rhs.staged { return !lhs.staged }
                if lhs.asleep != rhs.asleep { return lhs.asleep < rhs.asleep }
                return lhs.source > rhs.source
            }?
            .source
    }
}
