#if canImport(HealthKit)
import DawnCore
import Foundation
import HealthKit

/// Reads sleep analysis samples from Apple Health and watches for new ones.
public struct HealthKitSleepSource: SleepSampleSource {
    private let store: HKHealthStore

    public init(store: HKHealthStore = HKHealthStore()) {
        self.store = store
    }

    public func samples(in interval: DateInterval) async throws -> [SleepSample] {
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let query = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis), predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await query.result(for: store).compactMap { sample in
            guard let stage = HealthSleepMapping.stage(for: sample.value) else { return nil }
            return SleepSample(
                start: sample.startDate,
                end: sample.endDate,
                stage: stage,
                source: sample.sourceRevision.source.name
            )
        }
    }

    public func changes() -> AsyncStream<Void> {
        let store = store
        return AsyncStream { continuation in
            let query = HKObserverQuery(sampleType: HKCategoryType(.sleepAnalysis), predicate: nil) { _, done, _ in
                continuation.yield()
                done()
            }
            store.execute(query)
            continuation.onTermination = { _ in store.stop(query) }
        }
    }
}
#endif
