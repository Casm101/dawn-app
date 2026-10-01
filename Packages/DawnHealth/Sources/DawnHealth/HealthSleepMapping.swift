#if canImport(HealthKit)
import DawnCore
import HealthKit

/// Maps Health's sleep analysis values to stages. "In bed" maps to nothing: it says where someone was,
/// not whether they slept, and counting it alongside asleep samples would count the night twice.
public enum HealthSleepMapping {
    public static func stage(for value: Int) -> SleepStage? {
        switch HKCategoryValueSleepAnalysis(rawValue: value) {
        case .awake: .awake
        case .asleepREM: .rem
        case .asleepCore: .core
        case .asleepDeep: .deep
        case .asleepUnspecified: .unspecified
        case .inBed, .none: nil
        @unknown default: nil
        }
    }
}
#endif
