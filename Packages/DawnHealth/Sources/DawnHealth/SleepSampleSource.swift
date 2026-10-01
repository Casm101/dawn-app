import DawnCore
import Foundation

/// Where sleep samples come from. Apple Health sits behind it on device; tests use a fake.
public protocol SleepSampleSource: Sendable {
    /// Samples that overlap the interval, from every source the user allowed.
    func samples(in interval: DateInterval) async throws -> [SleepSample]
    /// Fires whenever new sleep samples may have arrived, for example Watch stages after waking.
    func changes() -> AsyncStream<Void>
}
