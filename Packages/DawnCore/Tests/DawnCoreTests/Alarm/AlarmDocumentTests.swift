import Foundation
import Testing
@testable import DawnCore

struct AlarmDocumentTests {
    private typealias A = AlarmFixture

    @Test func addingAnAlarmBumpsTheRevisionAndStampsIt() throws {
        var document = AlarmDocument()
        document.upsert(A.alarm(7, 0), at: A.at(0, "21:00"))
        #expect(document.revision == 1)
        #expect(document.updatedAt == A.at(0, "21:00"))
        #expect(try #require(document.alarms.first).updatedAt == A.at(0, "21:00"))
    }

    @Test func savingTheSameAlarmReplacesIt() {
        var document = AlarmDocument()
        var alarm = A.alarm(7, 0)
        document.upsert(alarm, at: A.at(0, "21:00"))
        alarm.time = ClockTime(hour: 6, minute: 45)!
        document.upsert(alarm, at: A.at(0, "21:05"))
        #expect(document.alarms.map(\.time) == [ClockTime(hour: 6, minute: 45)!])
        #expect(document.revision == 2)
    }

    @Test func alarmsStayInTimeOrder() {
        var document = AlarmDocument()
        document.upsert(A.alarm(9, 30, days: Weekday.weekend), at: A.at(0, "21:00"))
        document.upsert(A.alarm(7, 0), at: A.at(0, "21:01"))
        #expect(document.alarms.map(\.time.hour) == [7, 9])
    }

    @Test func removingAnAlarmBumpsTheRevision() throws {
        var document = AlarmDocument()
        let alarm = A.alarm(7, 0)
        document.upsert(alarm, at: A.at(0, "21:00"))
        document.remove(alarm.id, at: A.at(0, "21:10"))
        #expect(document.alarms.isEmpty)
        #expect(document.revision == 2)
    }

    @Test func removingAnUnknownAlarmChangesNothing() {
        var document = AlarmDocument()
        document.remove(UUID(), at: A.at(0, "21:10"))
        #expect(document.revision == 0)
    }

    @Test func snoozeAndWindowStayInsideTheirLimits() {
        let alarm = AlarmDefinition(time: ClockTime(hour: 7, minute: 0)!, snoozeMinutes: 90, windowMinutes: 2)
        #expect(alarm.snoozeMinutes == Tuning.Alarm.snoozeMinutes.upperBound)
        #expect(alarm.windowMinutes == Tuning.Alarm.windowMinutes.lowerBound)
    }

    @Test func theDocumentSurvivesAWriteAndARead() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathComponent("alarms.json")
        let file = JSONFile<AlarmDocument>(url: url)
        #expect(try file.read() == nil)
        var document = AlarmDocument()
        document.upsert(A.alarm(7, 0), at: A.at(0, "21:00"))
        try file.write(document)
        #expect(try file.read() == document)
    }
}
