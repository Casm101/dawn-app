import Foundation

/// One reading of wrist motion: acceleration with gravity removed, in g, and rotation rate, in
/// radians per second. Never stored; only epoch summaries are.
public struct MotionSample: Hashable, Sendable {
    public let date: Date
    public let acceleration: SIMD3<Double>
    public let rotation: SIMD3<Double>

    public init(date: Date, acceleration: SIMD3<Double>, rotation: SIMD3<Double> = .zero) {
        self.date = date
        self.acceleration = acceleration
        self.rotation = rotation
    }

    /// The size of the acceleration, in g.
    public var magnitude: Double {
        (acceleration * acceleration).sum().squareRoot()
    }
}
