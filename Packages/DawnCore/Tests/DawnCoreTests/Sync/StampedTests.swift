import Foundation
import Testing
@testable import DawnCore

struct StampedTests {
    private let earlier = SleepFixture.at(0, "21:00")
    private let later = SleepFixture.at(0, "22:00")

    @Test func anUnchangedValueKeepsItsStamp() {
        let stamped = Stamped(true, at: earlier, by: .phone)
        #expect(stamped.setting(true, at: later, by: .watch) == stamped)
    }

    @Test func aChangedValueTakesTheNewStamp() {
        let stamped = Stamped(true, at: earlier, by: .phone).setting(false, at: later, by: .watch)
        #expect(stamped == Stamped(false, at: later, by: .watch))
    }

    @Test func thePhoneWinsTies() {
        #expect(Replica.phone.winsTie(against: .watch))
        #expect(!Replica.watch.winsTie(against: .phone))
    }
}
