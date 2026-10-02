import DawnCore
import Foundation
@testable import DawnWrist

/// Motion the test pushes by hand.
final class FakeMotionStream: MotionStream, @unchecked Sendable {
    // Guarded by `lock`: the sink for the current stream.
    private let lock = NSLock()
    private var sink: AsyncStream<MotionSample>.Continuation?

    func start() async -> AsyncStream<MotionSample> {
        let (stream, sink) = AsyncStream<MotionSample>.makeStream()
        lock.withLock { self.sink = sink }
        return stream
    }

    func stop() async { lock.withLock { sink?.finish() } }

    func push(_ sample: MotionSample) { lock.withLock { _ = sink?.yield(sample) } }
}
