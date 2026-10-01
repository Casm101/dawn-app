import Foundation
import Testing
@testable import DawnCore

/// Where the alarm marker may be dragged, and the steps it moves in.
struct AlarmDragRangeTests {
    private typealias F = SleepFixture

    private func preview(ring: Date, nights: Int = 7, need: Double = 480, window: Int = 30) -> AlarmSleepPreview {
        let sessions = EnergyFixture.nights(nights, endingMorning: 7)
        let habitual = HabitualSleep(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "20:00"), calendar: F.calendar)
        return AlarmSleepPreview(ring: ring, habitual: habitual, need: F.minutes(need), windowMinutes: window, calendar: F.calendar)
    }

    @Test func aDraggedTimeSnapsToFiveMinuteSteps() {
        #expect(AlarmSleepPreview.snap(F.at(8, "06:52")) == F.at(8, "06:50"))
        #expect(AlarmSleepPreview.snap(F.at(8, "06:53")) == F.at(8, "06:55"))
    }

    @Test func theDragStaysOnTheRingsDayAfterBedtimeAndLateEnoughToSet() {
        // Day 8 is a Tuesday; an alarm on Tuesdays only cannot ring on day 7.
        let tuesdays = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, repeatDays: [.tuesday])
        let night = preview(ring: F.at(8, "07:00"))
        #expect(night.dragRange(for: tuesdays, now: F.at(7, "15:00"), calendar: F.calendar) == F.at(8, "00:00")...F.at(8, "23:55"))
        #expect(night.dragRange(for: tuesdays, now: F.at(8, "05:58"), calendar: F.calendar).lowerBound == F.at(8, "06:00"))
        let late = preview(ring: F.at(8, "23:30"))
        #expect(late.dragRange(for: tuesdays, now: F.at(7, "15:00"), calendar: F.calendar).lowerBound == F.at(8, "23:05"))
    }

    @Test(arguments: [
        (Weekday.weekdays, "07:30", 0),
        (Set<Weekday>(), "20:00", 0),
        (Set<Weekday>([.saturday, .sunday]), "22:00", 2),
    ])
    func everyTimeTheMarkerCanReachRingsOnTheSameDay(days: Set<Weekday>, clock: String, day: Int) throws {
        let alarm = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, repeatDays: days)
        let now = F.at(day, clock)
        let ring = try #require(AlarmOccurrence.next(alarm, after: now, calendar: F.calendar))
        let range = preview(ring: ring).dragRange(for: alarm, now: now, calendar: F.calendar)
        for end in [range.lowerBound, range.upperBound] {
            var moved = alarm
            moved.time = ClockTime(end, calendar: F.calendar)
            let landed = try #require(AlarmOccurrence.next(moved, after: now, calendar: F.calendar))
            #expect(F.calendar.isDate(landed, inSameDayAs: ring))
        }
    }

    @Test func todayCanRingSoTheMarkerStopsAtNowsClockTime() {
        let alarm = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!)
        #expect(preview(ring: F.at(1, "07:00")).dragRange(for: alarm, now: F.at(0, "07:30"), calendar: F.calendar).upperBound == F.at(1, "07:30"))
    }

    @Test func aBedtimeOffTheGridStillGivesALowerLimitOnAStep() {
        let sessions = EnergyFixture.nights(7, endingMorning: 7, bed: "00:37", wake: "08:00")
        let habitual = HabitualSleep(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "20:00"), calendar: F.calendar)
        let night = AlarmSleepPreview(ring: F.at(8, "08:00"), habitual: habitual, need: F.minutes(480), windowMinutes: 30, calendar: F.calendar)
        let tuesdays = AlarmSettings(time: ClockTime(hour: 8, minute: 0)!, repeatDays: [.tuesday])
        #expect(night.dragRange(for: tuesdays, now: F.at(7, "20:00"), calendar: F.calendar).lowerBound == F.at(8, "00:45"))
    }
}
