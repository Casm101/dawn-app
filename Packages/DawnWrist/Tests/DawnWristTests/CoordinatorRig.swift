import DawnCore
import Foundation
@testable import DawnWrist

/// A coordinator with every platform piece faked, its clock, alarms and foreground set by the test.
@MainActor
final class CoordinatorRig {
    let session = FakeWakeSession()
    let motion = FakeMotionStream()
    var heart = FakeHeartRateStream(answered: false)
    let nudges = FakeNudges()
    var alarms: [AlarmDefinition] = []
    var active = true
    var now: Date
    var sent: [WakeOutcome] = []
    let calendar = Calendar.current

    init() {
        now = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    }

    func coordinator() -> WakeCoordinator {
        WakeCoordinator(
            session: session, motion: motion, heart: heart, nudges: nudges,
            alarms: { [unowned self] in self.alarms }, send: { [unowned self] in self.sent.append($0) },
            isActive: { [unowned self] in self.active }, folder: nil, clock: { [unowned self] in self.now },
            calendar: calendar, checkInterval: .milliseconds(20)
        )
    }

    /// An every-day alarm ringing `hour`:`minute` tomorrow-or-today, with a window of `window` minutes.
    func setAlarm(hour: Int = 7, minute: Int = 0, window: Int = 30, on: Bool = true, id: UUID = UUID()) {
        var document = AlarmDocument()
        let settings = AlarmSettings(isEnabled: on, time: ClockTime(hour: hour, minute: minute)!, repeatDays: Set(Weekday.allCases), windowMinutes: window)
        alarms = [document.save(settings, id: id, at: now, by: .watch)]
    }

    var nextSeven: Date { calendar.nextDate(after: now, matching: DateComponents(hour: 7, minute: 0), matchingPolicy: .nextTime)! }
}
