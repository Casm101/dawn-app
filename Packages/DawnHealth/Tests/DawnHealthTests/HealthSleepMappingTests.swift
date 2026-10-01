#if canImport(HealthKit)
import DawnCore
import HealthKit
import Testing
@testable import DawnHealth

struct HealthSleepMappingTests {
    @Test func everyAsleepAndAwakeValueMapsToItsStage() {
        let pairs: [(HKCategoryValueSleepAnalysis, SleepStage)] = [
            (.awake, .awake), (.asleepREM, .rem), (.asleepCore, .core),
            (.asleepDeep, .deep), (.asleepUnspecified, .unspecified),
        ]
        for (value, stage) in pairs {
            #expect(HealthSleepMapping.stage(for: value.rawValue) == stage)
        }
    }

    @Test func inBedIsNotSleep() {
        #expect(HealthSleepMapping.stage(for: HKCategoryValueSleepAnalysis.inBed.rawValue) == nil)
    }

    @Test func unknownValuesAreIgnored() {
        #expect(HealthSleepMapping.stage(for: 99) == nil)
    }
}
#endif
