import DawnCore
import Foundation
import Testing
@testable import DawnSync

/// Relaunches, repeated deliveries and changes the receiving store makes itself.
@MainActor
struct AlarmSyncEngineRecoveryTests {
    @Test func aDeviceRelaunchedBeforeTheOtherSawItsChangeIsStillWaiting() async throws {
        let progress = JSONFile<SyncProgress>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        let (phoneLink, _) = FakeChannel.pair()
        phoneLink.cut(true)
        let store = FakeAlarmStore(replica: .phone)
        let before = AlarmSyncEngine(channel: phoneLink, replica: .phone, store: store, progressFile: progress)
        let first = Task { await before.run() }
        store.edit(UUID()) { _ in }
        before.localDidChange()
        try await eventually { before.isWaiting }
        first.cancel()

        let after = AlarmSyncEngine(channel: FakeChannel(), replica: .phone, store: store, progressFile: progress)
        let second = Task { await after.run() }
        defer { second.cancel() }
        try await eventually { after.isWaiting }
    }

    @Test func theSameCopyDeliveredTwiceIsMergedOnce() async throws {
        let (phoneLink, watchLink) = FakeChannel.pair()
        let phone = FakeAlarmStore(replica: .phone)
        phone.edit(UUID()) { _ in }
        let run = Task { await AlarmSyncEngine(channel: phoneLink, replica: .phone, store: phone).run() }
        defer { run.cancel() }
        try await eventually { phoneLink.publishCount == 1 }
        var fromWatch = AlarmDocument(origin: .watch)
        fromWatch.bump(at: Date(), by: .watch)
        try watchLink.publish(fromWatch)
        try await eventually { phoneLink.publishCount == 2 }
        try watchLink.publish(fromWatch)
        try await Task.sleep(for: .milliseconds(100))
        #expect(phoneLink.publishCount == 2)
    }

    @Test func aChangeTheReceivingStoreMakesGoesBack() async throws {
        let (phoneLink, watchLink) = FakeChannel.pair()
        let phone = FakeAlarmStore(replica: .phone), watch = FakeAlarmStore(replica: .watch)
        let id = UUID()
        phone.adjustNext = { document in
            var settings = document.alarm(id)!.settings
            settings.isEnabled = false
            document.save(settings, id: id, at: Date(), by: .phone)
        }
        let runs = [
            Task { await AlarmSyncEngine(channel: phoneLink, replica: .phone, store: phone).run() },
            Task { await AlarmSyncEngine(channel: watchLink, replica: .watch, store: watch).run() },
        ]
        defer { runs.forEach { $0.cancel() } }
        watch.edit(id, at: Date().addingTimeInterval(-1)) { $0.isEnabled = true }
        try await eventually { watch.document.alarm(id)?.settings.isEnabled == false }
        #expect(phone.document.sameContent(as: watch.document))
    }

    @Test func aCopyMergedBeforeAndHandedOverAgainOnLaunchLeavesNothingWaiting() async throws {
        let progress = JSONFile<SyncProgress>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        let store = FakeAlarmStore(replica: .phone)
        let id = UUID()
        store.edit(id, at: Date().addingTimeInterval(-60)) { _ in }
        var fromWatch = store.document
        fromWatch.origin = .watch
        fromWatch.bump(at: Date(), by: .watch)
        let before = AlarmSyncEngine(channel: FakeChannel(), replica: .phone, store: store, progressFile: progress)
        await before.receive(fromWatch)
        store.edit(id) { $0.time = ClockTime(hour: 6, minute: 0)! }
        before.localDidChange()
        try await eventually { before.isWaiting }
        await before.acknowledged(store.document.revision)
        #expect(!before.isWaiting)

        let link = FakeChannel()
        let after = AlarmSyncEngine(channel: link, replica: .phone, store: store, progressFile: progress)
        await after.receive(fromWatch)
        #expect(link.publishCount == 0)
        #expect(!after.isWaiting)
    }

    @Test(.timeLimit(.minutes(1)))
    func aSecondRunReturnsAtOnce() async {
        let sync = AlarmSyncEngine(channel: FakeChannel(), replica: .phone, store: FakeAlarmStore(replica: .phone))
        let first = Task { await sync.run() }
        defer { first.cancel() }
        try? await Task.sleep(for: .milliseconds(50))
        await sync.run()
    }
}
