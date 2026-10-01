/// Which way heart rate is moving over its last few samples.
public enum HeartRateTrend: String, Hashable, Sendable, Codable {
    case rising
    case stable
    case falling
    case unknown
}
