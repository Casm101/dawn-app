import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

/// Changes from the Watch meet the same rules as changes made on the phone.
@MainActor
struct AlarmLibraryRemoteTests {
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
    private let system = FakeAlarmScheduler()
    private let now = Date(timeIntervalSinceReferenceDate: 812_000_000)
    private let id = UUID()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func library(scheduler: any AlarmScheduling) -> AlarmLibrary {
        AlarmLibrary(
            file: JSONFile(url: url), sync: AlarmSystemSync(scheduler: scheduler),
            authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: calendar
        )
    }

    /// An alarm at a time some seconds from now, every day or once.
    private func settings(inSeconds seconds: TimeInterval = 3 * 3600, repeats: Bool = true) -> AlarmSettings {
        AlarmSettings(
            time: ClockTime(now.addingTimeInterval(seconds), calendar: calendar),
            repeatDays: repeats ? Set(Weekday.allCases) : []
        )
    }

    /// The phone's document with the Watch's change merged in, a minute after the phone saved it.
    private func fromWatch(_ alarms: AlarmLibrary, _ change: (inout AlarmSettings) -> Void) -> AlarmDocument {
        var remote = alarms.document
        var changed = remote.alarm(id)?.settings ?? settings()
        change(&changed)
        remote.save(changed, id: id, at: now.addingTimeInterval(60), by: .watch)
        return remote
    }

    @Test func anAlarmTheSystemRefusesIsSwitchedOffAndSentBack() async throws {
        let alarms = library(scheduler: system)
        await alarms.save(settings(), id: id, now: now)
        await system.refuseNext()
        let sendBack = await alarms.applyRemote(fromWatch(alarms) { $0.time = ClockTime(hour: 5, minute: 0)! }, at: now)
        #expect(sendBack)
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(alarms.problem == .couldNotSchedule(ClockTime(hour: 5, minute: 0)!))
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.alarm(id)?.settings.isEnabled == false)
    }

    @Test func anAlarmSwitchedOnWithoutPermissionIsSwitchedOff() async throws {
        let alarms = library(scheduler: system)
        await alarms.save(settings(), id: id, now: now)
        await alarms.setEnabled(false, for: id, now: now)
        alarms.permission = .denied
        let sendBack = await alarms.applyRemote(fromWatch(alarms) { $0.isEnabled = true }, at: now)
        #expect(sendBack)
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func changingOnlyTheWindowKeepsTheSystemAlarm() async {
        let alarms = library(scheduler: system)
        await alarms.save(settings(), id: id, now: now)
        let link = await alarms.systemLink(for: id)
        let sendBack = await alarms.applyRemote(fromWatch(alarms) { $0.windowMinutes = 15 }, at: now)
        #expect(!sendBack)
        #expect(await alarms.systemLink(for: id) == link)
        #expect(alarms.alarms.first?.settings.windowMinutes == 15)
    }

    @Test func aOneOffSetTooCloseToItsTimeOnTheWatchIsSwitchedOff() async throws {
        let alarms = library(scheduler: system)
        let soon = settings(inSeconds: 60, repeats: false)
        let sendBack = await alarms.applyRemote(fromWatch(alarms) { $0 = soon }, at: now)
        #expect(sendBack)
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(alarms.problem == .tooSoonToSet(soon.time))
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func aRepeatingAlarmMovedCloseToItsTimeIsScheduledWithANote() async throws {
        let alarms = library(scheduler: system)
        await alarms.save(settings(), id: id, now: now)
        let soon = settings(inSeconds: 60)
        let sendBack = await alarms.applyRemote(fromWatch(alarms) { $0.time = soon.time }, at: now)
        #expect(!sendBack)
        #expect(try await system.userAlarmIDs().count == 1)
        guard case .mayMissNextRing = alarms.problem else {
            Issue.record("expected a may-miss note, got \(String(describing: alarms.problem))")
            return
        }
    }

    @Test func aCheckOnReturningToTheAppDoesNotSwitchOffAnAlarmTheWatchJustAdded() async throws {
        let gated = GatedAlarmScheduler()
        await gated.open()
        let alarms = library(scheduler: gated)
        await alarms.save(settings(), id: id, now: now)
        let added = UUID()
        var remote = fromWatch(alarms) { $0.time = ClockTime(hour: 5, minute: 0)! }
        remote.save(settings(inSeconds: 4 * 3600), id: added, at: now.addingTimeInterval(60), by: .watch)
        await gated.close()
        let merging = Task { await alarms.applyRemote(remote, at: now) }
        await gated.waitForArrival()
        let returning = Task { await alarms.load(now: now) }
        try await Task.sleep(for: .milliseconds(100))
        await gated.open()
        _ = await merging.value
        await returning.value
        #expect(alarms.document.alarm(added)?.settings.isEnabled == true)
        #expect(try await gated.userAlarmIDs().count == 2)
    }
}
