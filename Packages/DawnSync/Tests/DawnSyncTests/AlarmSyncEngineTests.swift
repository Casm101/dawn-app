import DawnCore
import Foundation
import Testing
@testable import DawnSync

@MainActor
struct AlarmSyncEngineTests {
    /// Waits for a condition the engines reach asynchronously, failing after about two seconds.
    private func eventually(_ condition: () -> Bool) async throws {
        for _ in 0..<200 where !condition() { try await Task.sleep(for: .milliseconds(10)) }
        #expect(condition())
    }

    @Test func anAlarmSetOnOneDeviceReachesTheOtherAndEditsFlowBack() async throws {
        let (phoneLink, watchLink) = FakeChannel.pair()
        let phone = FakeAlarmStore(replica: .phone), watch = FakeAlarmStore(replica: .watch)
        let phoneSync = AlarmSyncEngine(channel: phoneLink, replica: .phone, store: phone)
        let watchSync = AlarmSyncEngine(channel: watchLink, replica: .watch, store: watch)
        let id = UUID()
        phone.edit(id) { _ in }
        let runs = [Task { await phoneSync.run() }, Task { await watchSync.run() }]
        defer { runs.forEach { $0.cancel() } }
        try await eventually { watch.document.alarm(id) != nil }

        watch.edit(id) { $0.time = ClockTime(hour: 6, minute: 30)! }
        watchSync.localDidChange()
        try await eventually { phone.document.alarm(id)?.settings.time == ClockTime(hour: 6, minute: 30)! }
        try await eventually { !phoneSync.isWaiting && !watchSync.isWaiting }
        #expect(phone.document.sameContent(as: watch.document))
    }

    @Test func theDevicesStopSendingOnceTheyAgree() async throws {
        let (phoneLink, watchLink) = FakeChannel.pair()
        let phone = FakeAlarmStore(replica: .phone), watch = FakeAlarmStore(replica: .watch)
        phone.edit(UUID()) { _ in }
        let runs = [
            Task { await AlarmSyncEngine(channel: phoneLink, replica: .phone, store: phone).run() },
            Task { await AlarmSyncEngine(channel: watchLink, replica: .watch, store: watch).run() },
        ]
        defer { runs.forEach { $0.cancel() } }
        try await eventually { phone.document.sameContent(as: watch.document) }
        try await Task.sleep(for: .milliseconds(200))
        let settled = phoneLink.publishCount + watchLink.publishCount
        try await Task.sleep(for: .milliseconds(200))
        #expect(phoneLink.publishCount + watchLink.publishCount == settled)
        #expect(settled <= 3)
    }

    @Test func aChangeTheOtherDeviceHasNotSeenIsWaitingAndNothingIsLost() async throws {
        let (phoneLink, watchLink) = FakeChannel.pair()
        let phone = FakeAlarmStore(replica: .phone), watch = FakeAlarmStore(replica: .watch)
        let phoneSync = AlarmSyncEngine(channel: phoneLink, replica: .phone, store: phone)
        let runs = [Task { await phoneSync.run() }, Task { await AlarmSyncEngine(channel: watchLink, replica: .watch, store: watch).run() }]
        defer { runs.forEach { $0.cancel() } }
        phoneLink.cut(true)
        let id = UUID()
        phone.edit(id) { _ in }
        phoneSync.localDidChange()
        try await eventually { phoneSync.isWaiting }
        phoneLink.cut(false)
        phoneSync.localDidChange()
        try await eventually { !phoneSync.isWaiting && watch.document.alarm(id) != nil }
    }

    @Test func theRefreshOnStartingDoesNotLeaveTheDeviceWaiting() async throws {
        let store = FakeAlarmStore(replica: .phone)
        store.edit(UUID()) { _ in }
        let link = FakeChannel()
        let sync = AlarmSyncEngine(channel: link, replica: .phone, store: store)
        let run = Task { await sync.run() }
        defer { run.cancel() }
        try await eventually { link.publishCount == 1 }
        #expect(!sync.isWaiting)
    }

    @Test func withoutAnotherDeviceNothingIsWaiting() async throws {
        let store = FakeAlarmStore(replica: .phone)
        let sync = AlarmSyncEngine(channel: FakeChannel(hasCounterpart: false), replica: .phone, store: store)
        let run = Task { await sync.run() }
        defer { run.cancel() }
        store.edit(UUID()) { _ in }
        sync.localDidChange()
        try await Task.sleep(for: .milliseconds(100))
        #expect(!sync.isWaiting)
    }
}
