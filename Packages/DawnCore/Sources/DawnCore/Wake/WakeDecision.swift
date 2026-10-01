import Foundation

/// Decides, epoch by epoch, when the window wakes the wearer: movement for two epochs in a row
/// after the warm-up, a strong burst after the start guard, or the deadline. Keeps only scores and
/// counts, never samples.
public struct WakeDecision: Sendable {
    private typealias T = Tuning.Wake

    /// Seconds from the window's start at which it fires regardless.
    public let deadline: TimeInterval
    public private(set) var trigger: WakeTrigger?
    public private(set) var epochs = 0
    public private(set) var peakScore = 0.0
    public private(set) var usedHeartRate = false
    private var history: [WakeEpoch] = []
    private var above = 0

    /// For a window `length` long, in a session that may end sooner.
    public init(length: TimeInterval, sessionLength: TimeInterval? = nil) {
        deadline = max(0, min(length, sessionLength ?? length) - T.safetyMargin)
    }

    /// Takes the next epoch and returns the trigger once the window has fired.
    public mutating func add(_ epoch: WakeEpoch) -> WakeTrigger? {
        guard trigger == nil else { return trigger }
        let score = ArousalScorer.score(epoch, baseline: ArousalBaseline(history: history.suffix(T.baselineEpochs)))
        history = Array((history + [epoch]).suffix(T.baselineEpochs))
        epochs += 1
        peakScore = max(peakScore, score.combined)
        usedHeartRate = usedHeartRate || score.usedHeartRate
        if score.isStrongBurst && epoch.elapsed > T.burstGuard {
            trigger = .strongBurst
        } else if epoch.elapsed - T.epoch >= T.warmUp {
            above = score.combined >= T.threshold ? above + 1 : 0
            if above >= T.sustainedEpochs { trigger = score.usedHeartRate ? .stirringWithHeartRate : .stirring }
        }
        return trigger ?? reached(epoch.elapsed)
    }

    /// Fires at the deadline when nothing has fired before it.
    public mutating func reached(_ elapsed: TimeInterval) -> WakeTrigger? {
        if trigger == nil, elapsed >= deadline { trigger = .windowEnd }
        return trigger
    }

    /// Fires because the system is about to end the session.
    public mutating func expiring() -> WakeTrigger {
        if trigger == nil { trigger = .sessionExpiring }
        return trigger ?? .sessionExpiring
    }
}
