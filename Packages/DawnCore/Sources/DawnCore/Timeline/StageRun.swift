import Foundation

/// A stretch of one stage, for drawing the stage rail: consecutive samples of the same stage merge.
public struct StageRun: Hashable, Sendable {
    public let start: Date
    public let end: Date
    public let stage: SleepStage

    /// Runs of the sessions' staged samples inside the window, in time order. Empty when no
    /// sample carries a stage, so a night without stages draws no rail at all.
    public static func runs(of sessions: [SleepSession], in window: DateInterval) -> [StageRun] {
        let samples = sessions.filter { $0.stageTotals != nil }.flatMap(\.samples).sorted { $0.start < $1.start }
        var runs: [StageRun] = []
        for sample in samples {
            let start = max(sample.start, window.start), end = min(sample.end, window.end)
            guard start < end else { continue }
            if let last = runs.last, last.stage == sample.stage, last.end >= start {
                runs[runs.count - 1] = StageRun(start: last.start, end: max(last.end, end), stage: last.stage)
            } else {
                runs.append(StageRun(start: start, end: end, stage: sample.stage))
            }
        }
        return runs
    }
}
