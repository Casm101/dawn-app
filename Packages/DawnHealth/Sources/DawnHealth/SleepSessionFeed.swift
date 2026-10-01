import DawnCore
import Foundation

/// Reads recent sleep from a source as sessions, and reads again whenever the source reports a change.
public struct SleepSessionFeed: Sendable {
    private let source: any SleepSampleSource
    private let calendar: Calendar
    private let now: @Sendable () -> Date

    public init(
        source: any SleepSampleSource,
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.source = source
        self.calendar = calendar
        self.now = now
    }

    /// Sessions from the start of the day `Tuning.Sleep.importDays` ago until now.
    public func load() async throws -> [SleepSession] {
        let end = now()
        let today = calendar.startOfDay(for: end)
        let start = calendar.date(byAdding: .day, value: -Tuning.Sleep.importDays, to: today) ?? today
        let samples = try await source.samples(in: DateInterval(start: start, end: end))
        return SessionGrouper.sessions(from: samples, calendar: calendar)
    }

    /// Each read's result: the sessions now, then again after every change the source reports, until
    /// cancelled. A failed read is reported and the feed carries on with the next change.
    public func updates() -> AsyncStream<Result<[SleepSession], any Error>> {
        let feed = self
        return AsyncStream { continuation in
            let task = Task {
                let changes = feed.source.changes()
                continuation.yield(await feed.result())
                for await _ in changes {
                    continuation.yield(await feed.result())
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func result() async -> Result<[SleepSession], any Error> {
        do { return .success(try await load()) } catch { return .failure(error) }
    }
}
