import DawnCore
import Foundation

/// Turns the samples arriving while a window runs into 30-second epochs and decides when to wake.
/// Holds one epoch of motion and the last few heart-rate readings, and drops them as it goes.
public actor WakeMonitor {
    private let plan: WakePlan
    private let start: Date
    private var decision: WakeDecision
    private var motion: [MotionSample] = []
    private var heartRates: [HeartRateSample] = []
    private var heartRateCount = 0
    private var motionEpochs = 0
    private var closed: TimeInterval = 0

    /// For a window that began running at `start`, in a session the system ends at `sessionEnds`.
    public init(plan: WakePlan, start: Date, sessionEnds: Date? = nil) {
        self.plan = plan
        self.start = start
        decision = WakeDecision(
            length: plan.windowEnd.timeIntervalSince(start), sessionLength: sessionEnds.map { $0.timeIntervalSince(start) }
        )
    }

    public func ingest(_ sample: MotionSample) {
        motion.append(sample)
    }

    public func ingest(_ sample: HeartRateSample) {
        heartRates = Array((heartRates + [sample]).suffix(Tuning.Wake.baselineEpochs))
        heartRateCount += 1
    }

    /// Closes every epoch that has ended by `date` and returns the trigger once the window should wake.
    public func tick(at date: Date) -> WakeTrigger? {
        let elapsed = date.timeIntervalSince(start)
        while elapsed - closed >= Tuning.Wake.epoch {
            closed += Tuning.Wake.epoch
            let epoch = WakeEpoch(start: start, elapsed: closed, motion: motion, heartRates: heartRates)
            motion.removeAll { $0.date <= start.addingTimeInterval(closed) }
            if epoch.motion.hasMotion { motionEpochs += 1 }
            if let trigger = decision.add(epoch) { return trigger }
        }
        return decision.reached(elapsed)
    }

    /// The system is about to end the session.
    public func expiring() -> WakeTrigger { decision.expiring() }

    /// Motion samples still held, for tests: never more than one epoch's worth.
    public var heldSamples: Int { motion.count }

    /// What the window did, with only aggregate diagnostics.
    public func outcome(result: WakeResult, firedAt: Date?) -> WakeOutcome {
        WakeOutcome(
            alarmID: plan.alarmID, windowStart: plan.windowStart, windowEnd: plan.windowEnd, result: result,
            firedAt: firedAt, trigger: decision.trigger, usedMotion: motionEpochs > 0,
            usedHeartRate: decision.usedHeartRate, epochs: decision.epochs, peakScore: decision.peakScore,
            heartRateSamples: heartRateCount
        )
    }
}
