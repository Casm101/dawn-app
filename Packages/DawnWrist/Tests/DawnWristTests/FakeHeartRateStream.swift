import DawnCore
import Foundation
@testable import DawnWrist

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
