import Foundation

/// Scores an epoch against tonight's baseline (WakeTF's wake scorer, MIT, on 30-second epochs).
/// Motion alone is enough; heart rate only adds when a fresh sample exists; no motion scores zero.
public enum ArousalScorer {
    private typealias T = Tuning.Wake

    public static func score(_ epoch: WakeEpoch, baseline: ArousalBaseline) -> ArousalScore {
        let motion = motionScore(epoch.motion, baseline: baseline)
        let heart = heartRateScore(epoch.heartRate, baseline: baseline)
        let usesHeart = epoch.motion.hasMotion && epoch.heartRate.isFresh
        let combined: Double
        if !epoch.motion.hasMotion {
            combined = 0
        } else if usesHeart {
            combined = motion * (1 - T.heartRateShare) + heart * T.heartRateShare
        } else {
            combined = motion
        }
        return ArousalScore(
            motion: motion, heartRate: heart, combined: combined, usedHeartRate: usesHeart,
            isStrongBurst: epoch.motion.peak >= T.strongBurst
        )
    }

    private static func motionScore(_ motion: MotionFeatures, baseline: ArousalBaseline) -> Double {
        guard motion.hasMotion else { return 0 }
        let deviation = (motion.rms - baseline.motionMedian) / baseline.motionSpread
        let weights = T.motionWeights
        return unit(deviation / T.fullDeviation) * weights.rms
            + unit(Double(motion.bursts) / T.fullBursts) * weights.bursts
            + unit(motion.peak / T.fullPeak) * weights.peak
            + unit(motion.rotationDelta) * weights.rotation
    }

    private static func heartRateScore(_ heart: HeartRateFeatures, baseline: ArousalBaseline) -> Double {
        guard let current = heart.current else { return 0 }
        var score = baseline.heartRate.map { unit((current - $0) / T.fullRise) * T.riseWeight } ?? 0
        switch heart.trend {
        case .rising: score += T.risingTrend
        case .stable: score += T.stableTrend
        case .falling, .unknown: break
        }
        return min(score, 1)
    }

    private static func unit(_ value: Double) -> Double { min(max(value, 0), 1) }
}
