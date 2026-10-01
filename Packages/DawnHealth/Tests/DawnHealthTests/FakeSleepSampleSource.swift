import DawnCore
import Foundation
@testable import DawnHealth

/// Hands back whatever samples a test gives it, and reports a change when the test says so.
actor FakeSleepSampleSource: SleepSampleSource {
    private var stored: [SleepSample]
    private(set) var requested: [DateInterval] = []
    private var failNextRead = false
    private nonisolated let stream: AsyncStream<Void>
    private nonisolated let continuation: AsyncStream<Void>.Continuation

    init(samples: [SleepSample]) {
        stored = samples
        (stream, continuation) = AsyncStream.makeStream(of: Void.self)
    }

    func samples(in interval: DateInterval) async throws -> [SleepSample] {
        requested.append(interval)
        if failNextRead {
            failNextRead = false
            throw CocoaError(.fileReadUnknown)
        }
        return stored.filter { $0.end > interval.start && $0.start < interval.end }
    }

    nonisolated func changes() -> AsyncStream<Void> { stream }

    func replace(with samples: [SleepSample]) { stored = samples }

    func failOnce() { failNextRead = true }

    nonisolated func reportChange() { continuation.yield() }
}
