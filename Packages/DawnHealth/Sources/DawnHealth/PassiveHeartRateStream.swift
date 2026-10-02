#if canImport(HealthKit)
import DawnCore
import Foundation
import HealthKit

/// Passive heart rate from HealthKit through an anchored query, from five minutes before the start
/// onward (heart-rate monitor from WakeTF, MIT). No workout session, so readings are sparse.
public actor PassiveHeartRateStream: HeartRateStream {
    private var query: HKAnchoredObjectQuery?
    private let rate = HKQuantityType(.heartRate)

    public init() {}

    public func authorize() async -> Bool {
        do {
            try await SharedHealthStore.store.requestAuthorization(toShare: [], read: [rate])
            return true
        } catch {
            return false
        }
    }

    public func canRead() async -> Bool {
        let status = try? await SharedHealthStore.store.statusForAuthorizationRequest(toShare: [], read: [rate])
        return status == .unnecessary
    }

    public func start() async -> AsyncStream<HeartRateSample> {
        stopQuery()
        let (stream, sink) = AsyncStream<HeartRateSample>.makeStream()
        let since = Date().addingTimeInterval(-Tuning.Wake.heartRateFreshness)
        let deliver: @Sendable ([HKSample]?) -> Void = { samples in
            for case let sample as HKQuantitySample in samples ?? [] {
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                sink.yield(HeartRateSample(date: sample.endDate, beatsPerMinute: bpm))
            }
        }
        let query = HKAnchoredObjectQuery(
            type: rate, predicate: HKQuery.predicateForSamples(withStart: since, end: nil), anchor: nil, limit: HKObjectQueryNoLimit
        ) { _, samples, _, _, _ in deliver(samples) }
        query.updateHandler = { _, samples, _, _, _ in deliver(samples) }
        self.query = query
        SharedHealthStore.store.execute(query)
        return stream
    }

    public func stop() async {
        stopQuery()
    }

    private func stopQuery() {
        if let query { SharedHealthStore.store.stop(query) }
        query = nil
    }
}
#endif
