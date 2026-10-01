import DawnCore
import Foundation
@testable import DawnSync

/// One end of an in-memory link between two devices. Whatever one end publishes or acknowledges
/// arrives at the other, unless the link is cut.
final class FakeChannel: AlarmDocumentChannel, @unchecked Sendable {
    // Guarded by `lock`: the peer, the cut switch and the publish count.
    private let lock = NSLock()
    private weak var peer: FakeChannel?
    private var isCut = false
    private var published = 0
    private let hasCounterpart: Bool
    let documents: AsyncStream<AlarmDocument>
    let acknowledgements: AsyncStream<Int>
    private let documentSink: AsyncStream<AlarmDocument>.Continuation
    private let ackSink: AsyncStream<Int>.Continuation

    init(hasCounterpart: Bool = true) {
        self.hasCounterpart = hasCounterpart
        (documents, documentSink) = AsyncStream.makeStream()
        (acknowledgements, ackSink) = AsyncStream.makeStream()
    }

    static func pair() -> (FakeChannel, FakeChannel) {
        let a = FakeChannel(), b = FakeChannel()
        a.lock.withLock { a.peer = b }
        b.lock.withLock { b.peer = a }
        return (a, b)
    }

    var publishCount: Int { lock.withLock { published } }
    func cut(_ cut: Bool) { lock.withLock { isCut = cut } }

    func activate() async {}
    func counterpartAvailable() async -> Bool { hasCounterpart }

    func publish(_ document: AlarmDocument) throws {
        let peer = lock.withLock { () -> FakeChannel? in
            published += 1
            return isCut ? nil : self.peer
        }
        peer?.documentSink.yield(document)
    }

    func acknowledge(_ revision: Int) {
        let peer = lock.withLock { isCut ? nil : self.peer }
        peer?.ackSink.yield(revision)
    }
}
