import Testing
@testable import DawnCore

struct EnergyPotentialTests {
    @Test func noDebtIsFullPotential() {
        #expect(EnergyPotential.percent(debtHours: 0) == 100)
    }

    @Test func eachHourOfDebtCostsAboutTwoPoints() {
        #expect(EnergyPotential.percent(debtHours: 5) == 90)
        #expect(EnergyPotential.percent(debtHours: 10) == 79)
    }

    @Test func potentialNeverFallsBelowTwenty() {
        #expect(EnergyPotential.percent(debtHours: 60) == 20)
    }
}
