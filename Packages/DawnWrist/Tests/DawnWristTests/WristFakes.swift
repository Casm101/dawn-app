import DawnCore
import Foundation
@testable import DawnWrist

/// A session that only reports what the test says, and records what it was asked to do.
@MainActor
final class FakeWakeSession: WakeSessionControl {
    let events: AsyncStream<WakeSessionEvent>
    private let sink: AsyncStream<WakeSessionEvent>.Continuation
    var isPending = false
    private(set) var scheduled: [Date] = []
    private(set) var wakes = 0
    private(set) var cancels = 0

    init() { (events, sink) = AsyncStream.makeStream() }

    func schedule(at date: Date) async {
        scheduled.append(date)
        isPending = true
    }

    func wake() { wakes += 1 }

    func cancel() {
        cancels += 1
        isPending = false
    }

    func emit(_ event: WakeSessionEvent) { sink.yield(event) }
}

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

/// Heart rate whose permission question the test answers, and that never sends readings. With
/// `hangs`, the question is never answered, as when the wearer ignores the prompt.
actor FakeHeartRateStream: HeartRateStream {
    private(set) var asked = 0
    private(set) var started = 0
    private let answered: Bool
    private let hangs: Bool

    init(answered: Bool, hangs: Bool = false) {
        self.answered = answered
        self.hangs = hangs
    }

    func authorize() async -> Bool {
        asked += 1
        if hangs { try? await Task.sleep(for: .seconds(3600)) }
        return answered
    }

    func canRead() async -> Bool { answered }

    func start() async -> AsyncStream<HeartRateSample> {
        started += 1
        return AsyncStream { $0.finish() }
    }

    func stop() async {}
}

/// Remembers the last reminder and card it was asked for.
actor FakeNudges: WakeNudging {
    private(set) var reminder: Date??
    private(set) var widget: DateInterval??

    func remind(at date: Date?) async { reminder = .some(date) }
    func offerWidget(during interval: DateInterval?) async { widget = .some(interval) }
}
