import Testing
@testable import DawnCore

struct DebtBandTests {
    @Test func underFiveHoursIsOkay() {
        #expect(DebtBand(hours: 0) == .okay)
        #expect(DebtBand(hours: 4.99) == .okay)
    }

    @Test func fiveToTenHoursIsBuilding() {
        #expect(DebtBand(hours: 5) == .building)
        #expect(DebtBand(hours: 10) == .building)
    }

    @Test func overTenHoursIsHigh() {
        #expect(DebtBand(hours: 10.01) == .high)
    }
}
