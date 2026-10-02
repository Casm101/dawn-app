import Foundation

/// What one epoch's wrist motion amounts to (feature extraction from WakeTF's motion monitor, MIT).
public struct MotionFeatures: Hashable, Sendable, Codable {
    /// Root mean square of the acceleration magnitudes, in g.
    public var rms: Double
    public var variance: Double
    /// The largest single magnitude, in g.
    public var peak: Double
    /// Samples above `Tuning.Wake.burstMagnitude`.
    public var bursts: Int
    /// How much the rotation rate changed between the epoch's first and last sample.
    public var rotationDelta: Double
    public var sampleCount: Int

    public init(rms: Double = 0, variance: Double = 0, peak: Double = 0, bursts: Int = 0, rotationDelta: Double = 0, sampleCount: Int = 0) {
        self.rms = rms
        self.variance = variance
        self.peak = peak
        self.bursts = bursts
        self.rotationDelta = rotationDelta
        self.sampleCount = sampleCount
    }

    public init(samples: [MotionSample]) {
        guard samples.count >= 2, let first = samples.first, let last = samples.last else {
            self.init(sampleCount: samples.count)
            return
        }
        let magnitudes = samples.map(\.magnitude)
        let count = Double(magnitudes.count)
        let mean = magnitudes.reduce(0, +) / count
        let change = last.rotation - first.rotation
        self.init(
            rms: (magnitudes.reduce(0) { $0 + $1 * $1 } / count).squareRoot(),
            variance: magnitudes.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / count,
            peak: magnitudes.max() ?? 0,
            bursts: magnitudes.filter { $0 > Tuning.Wake.burstMagnitude }.count,
            rotationDelta: (change * change).sum().squareRoot(),
            sampleCount: samples.count
        )
    }

    public var hasMotion: Bool { sampleCount >= 2 }
}
