#if canImport(HealthKit)
import HealthKit

/// The app's one Health store, shared by every HealthKit adapter, as Apple recommends.
public enum SharedHealthStore {
    public static let store = HKHealthStore()
}
#endif
