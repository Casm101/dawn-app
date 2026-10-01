import DawnCore
import Foundation
import Testing
@testable import DawnUI

struct DebtBandStyleTests {
    private let english = Locale(identifier: "en")

    @Test func bandsReadOkayBuildingAndHigh() {
        #expect(DebtBandStyle.label(.okay, locale: english) == "Okay")
        #expect(DebtBandStyle.label(.building, locale: english) == "Building")
        #expect(DebtBandStyle.label(.high, locale: english) == "High")
    }

    @Test func everyBandHasItsOwnColour() {
        #expect(Set(DebtBand.allCases.map(DebtBandStyle.color)).count == DebtBand.allCases.count)
    }
}
