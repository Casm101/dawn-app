import Foundation
import Testing
@testable import DawnCore

struct WakeArmingTests {
    private typealias F = SleepFixture
    private let plan = WakePlan(alarmID: UUID(), windowStart: F.at(1, "06:30"), windowEnd: F.at(1, "07:00"))

    @Test func aPlanAlreadyArmedWithItsSessionWaitingIsNotArmedAgain() {
        let arming = WakeArming(armed: plan)
        #expect(arming.toArm(plan, sessionPending: true) == nil)
        #expect(arming.toArm(plan, sessionPending: false) == plan)
        let other = WakePlan(alarmID: plan.alarmID, windowStart: F.at(1, "06:40"), windowEnd: F.at(1, "07:00"))
        #expect(arming.toArm(other, sessionPending: true) == other)
    }

    @Test func wakingMarksTheRingDoneSoTheNextNightIsArmed() {
        var arming = WakeArming(armed: plan)
        arming.woke()
        #expect(arming.armed == nil)
        #expect(arming.completedRing == F.at(1, "07:00"))
    }

    @Test func endingWithoutWakingLeavesTheRingOpen() {
        var arming = WakeArming(armed: plan, completedRing: F.at(0, "07:00"))
        arming.ended()
        #expect(arming.armed == nil)
        #expect(arming.completedRing == F.at(0, "07:00"))
    }
}
