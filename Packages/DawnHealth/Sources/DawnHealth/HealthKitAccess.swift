#if canImport(HealthKit)
import HealthKit

/// Asks Apple Health for permission to read sleep.
public struct HealthKitAccess: HealthAccess {
    private let store: HKHealthStore
    private let sleep: Set<HKObjectType> = [HKCategoryType(.sleepAnalysis)]

    public init(store: HKHealthStore = SharedHealthStore.store) {
        self.store = store
    }

    public func state() async -> HealthAccessState {
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        switch try? await store.statusForAuthorizationRequest(toShare: [], read: sleep) {
        case .unnecessary: return .granted
        default: return .notDetermined
        }
    }

    public func requestSleepRead() async -> HealthAccessState {
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        try? await store.requestAuthorization(toShare: [], read: sleep)
        return await state()
    }
}
#endif
