import Foundation
import Testing
@testable import DawnCore

struct AlarmDocumentTests {
    private typealias A = AlarmFixture

    @Test func savingANewAlarmBumpsTheRevisionAndStampsEveryField() throws {
        var document = AlarmDocument()
        let alarm = document.save(A.alarm(7, 0), id: UUID(), at: A.at(0, "21:00"), by: .phone)
        #expect(document.revision == 1)
        #expect(document.updatedAt == A.at(0, "21:00"))
        #expect(document.origin == .phone)
        #expect(alarm.wakeTime == Stamped(ClockTime(hour: 7, minute: 0)!, at: A.at(0, "21:00"), by: .phone))
        #expect(alarm.enabled.updatedAt == A.at(0, "21:00"))
    }

    @Test func savingAgainRestampsOnlyWhatChanged() throws {
        var document = AlarmDocument()
        let id = UUID()
        document.save(A.alarm(7, 0), id: id, at: A.at(0, "21:00"), by: .phone)
        var settings = A.alarm(7, 0)
        settings.time = ClockTime(hour: 6, minute: 45)!
        let alarm = document.save(settings, id: id, at: A.at(0, "21:05"), by: .watch)
        #expect(alarm.wakeTime == Stamped(ClockTime(hour: 6, minute: 45)!, at: A.at(0, "21:05"), by: .watch))
        #expect(alarm.repeatDays.updatedAt == A.at(0, "21:00"))
        #expect(alarm.repeatDays.origin == .phone)
        #expect(document.alarms.count == 1)
        #expect(document.revision == 2)
        #expect(document.origin == .watch)
    }

    @Test func alarmsStayInTimeOrder() {
        var document = AlarmDocument()
        document.save(A.alarm(9, 30, days: Weekday.weekend), id: UUID(), at: A.at(0, "21:00"), by: .phone)
        document.save(A.alarm(7, 0), id: UUID(), at: A.at(0, "21:01"), by: .phone)
        #expect(document.alarms.map(\.settings.time.hour) == [7, 9])
    }

    @Test func removingAnAlarmBumpsTheRevision() {
        var document = AlarmDocument()
        let id = UUID()
        document.save(A.alarm(7, 0), id: id, at: A.at(0, "21:00"), by: .phone)
        document.remove(id, at: A.at(0, "21:10"), by: .phone)
        #expect(document.alarms.isEmpty)
        #expect(document.revision == 2)
    }

    @Test func removingAnUnknownAlarmChangesNothing() {
        var document = AlarmDocument()
        document.remove(UUID(), at: A.at(0, "21:10"), by: .phone)
        #expect(document.revision == 0)
    }

    @Test func snoozeAndWindowStayInsideTheirLimits() {
        let settings = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, snoozeMinutes: 90, windowMinutes: 2)
        #expect(settings.snoozeMinutes == Tuning.Alarm.snoozeMinutes.upperBound)
        #expect(settings.windowMinutes == Tuning.Alarm.windowMinutes.lowerBound)
    }

    @Test func editStampsKeepTheirSubsecondPrecision() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        let file = JSONFile<AlarmDocument>(url: url)
        var document = AlarmDocument()
        document.save(A.alarm(7, 0), id: UUID(), at: A.at(0, "21:00").addingTimeInterval(0.123_456), by: .phone)
        try file.write(document)
        #expect(try file.read() == document)
    }

    @Test func theDocumentSurvivesAWriteAndARead() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathComponent("alarms.json")
        let file = JSONFile<AlarmDocument>(url: url)
        #expect(try file.read() == nil)
        var document = AlarmDocument()
        document.save(A.alarm(7, 0), id: UUID(), at: A.at(0, "21:00"), by: .phone)
        try file.write(document)
        #expect(try file.read() == document)
    }
}
