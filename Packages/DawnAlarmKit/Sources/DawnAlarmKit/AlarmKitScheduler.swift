#if canImport(AlarmKit)
import ActivityKit
import AlarmKit
import DawnCore
import Foundation
import SwiftUI

/// Schedules Dawn's alarms with AlarmKit, so they ring through Silent and Focus with the app closed.
public struct AlarmKitScheduler: AlarmScheduling {
    private let copy: AlarmAlertCopy
    private let tint: Color

    public init(copy: AlarmAlertCopy, tint: Color) {
        self.copy = copy
        self.tint = tint
    }

    public func schedule(id: UUID, alarm: AlarmSettings) async throws {
        let time = Alarm.Schedule.Relative.Time(hour: alarm.time.hour, minute: alarm.time.minute)
        let repeats: Alarm.Schedule.Relative.Recurrence = alarm.repeats
            ? .weekly(alarm.repeatDays.sorted().map(\.localeWeekday))
            : .never
        let configuration = AlarmManager.AlarmConfiguration<DawnAlarmMetadata>(
            countdownDuration: Alarm.CountdownDuration(preAlert: nil, postAlert: Double(alarm.snoozeMinutes) * 60),
            schedule: .relative(.init(time: time, repeats: repeats)),
            attributes: attributes(snoozes: true),
            sound: .named(alarm.sound.fileName)
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
    }

    public func schedule(id: UUID, at date: Date, alarm: AlarmSettings) async throws {
        let configuration = AlarmManager.AlarmConfiguration<DawnAlarmMetadata>(
            countdownDuration: Alarm.CountdownDuration(preAlert: nil, postAlert: Double(alarm.snoozeMinutes) * 60),
            schedule: .fixed(date),
            attributes: attributes(snoozes: true),
            sound: .named(alarm.sound.fileName)
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
    }

    public func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm {
        let configuration = AlarmManager.AlarmConfiguration<DawnAlarmMetadata>(
            schedule: .fixed(fireDate), attributes: attributes(snoozes: false)
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        return ScheduledAlarm(id: id, fireDate: fireDate)
    }

    public func cancel(id: UUID) async throws {
        try AlarmManager.shared.cancel(id: id)
    }

    public func scheduled() async -> [ScheduledAlarm] {
        let alarms = (try? AlarmManager.shared.alarms) ?? []
        return alarms.compactMap { alarm in
            guard case .fixed(let date) = alarm.schedule else { return nil }
            return ScheduledAlarm(id: alarm.id, fireDate: date)
        }
    }

    public func userAlarmIDs() async throws -> Set<UUID> {
        Set(try AlarmManager.shared.alarms.compactMap { alarm in
            guard case .relative = alarm.schedule else { return nil }
            return alarm.id
        })
    }

    /// Snooze needs a countdown length, so only alarms scheduled with one offer it.
    private func attributes(snoozes: Bool) -> AlarmAttributes<DawnAlarmMetadata> {
        let stop = AlarmButton(text: copy.stop, textColor: .white, systemImageName: "stop.circle")
        let snooze = AlarmButton(text: copy.snooze, textColor: .white, systemImageName: "zzz")
        // The initialiser without a stop button needs iOS 26.1; the floor is 26.0, so this one is
        // used and its deprecation warning accepted. The system draws its own Stop either way.
        let alert = AlarmPresentation.Alert(
            title: copy.title, stopButton: stop,
            secondaryButton: snoozes ? snooze : nil, secondaryButtonBehavior: snoozes ? .countdown : nil
        )
        let presentation = AlarmPresentation(alert: alert, countdown: .init(title: copy.snoozing))
        return AlarmAttributes(presentation: presentation, metadata: DawnAlarmMetadata(), tintColor: tint)
    }
}
#endif
