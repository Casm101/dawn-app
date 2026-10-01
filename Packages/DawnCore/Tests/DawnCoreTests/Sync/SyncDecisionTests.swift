import Foundation
import Testing
@testable import DawnCore

struct SyncDecisionTests {
    private let t0 = SleepFixture.at(0, "20:00")
    private let settings = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!)

    @Test func aNewerCopyIsTakenAndNotSentBack() {
        let local = AlarmDocument()
        var remote = AlarmDocument()
        remote.save(settings, id: UUID(), at: t0, by: .phone)
        let decision = SyncDecision(local: local, remote: remote, at: t0, by: .watch)
        #expect(decision.changedHere)
        #expect(!decision.sendBack)
    }

    @Test func somethingTheOtherSideLacksIsSentBackWithAHigherRevision() {
        var local = AlarmDocument()
        local.save(settings, id: UUID(), at: t0, by: .watch)
        let remote = AlarmDocument(revision: 5)
        let decision = SyncDecision(local: local, remote: remote, at: t0, by: .watch)
        #expect(decision.sendBack)
        #expect(decision.document.revision == 6)
    }

    @Test func anIdenticalCopyNeedsNothing() {
        var local = AlarmDocument()
        local.save(settings, id: UUID(), at: t0, by: .phone)
        let decision = SyncDecision(local: local, remote: local, at: t0, by: .watch)
        #expect(!decision.changedHere)
        #expect(!decision.sendBack)
    }

    @Test func aDocumentSavedBeforeDeletionsWereRecordedStillReads() throws {
        var document = AlarmDocument()
        document.save(settings, id: UUID(), at: t0, by: .phone)
        var json = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(document)) as? [String: Any])
        json["tombstones"] = nil
        let old = try JSONDecoder().decode(AlarmDocument.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(old.alarms == document.alarms)
        #expect(old.tombstones.isEmpty)
    }
}
