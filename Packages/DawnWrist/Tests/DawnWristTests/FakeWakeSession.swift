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

    /// Like invalidating a real session, which reports that it ended.
    func cancel() {
        cancels += 1
        isPending = false
        sink.yield(.ended(failed: false))
    }

    func emit(_ event: WakeSessionEvent) {
        if case .ended = event { isPending = false }
        sink.yield(event)
    }
}
