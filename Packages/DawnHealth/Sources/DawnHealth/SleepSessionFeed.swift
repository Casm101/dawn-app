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

    /// The sessions now, then again after every change the source reports, until cancelled.
    public func updates() -> AsyncThrowingStream<[SleepSession], any Error> {
        let feed = self
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    continuation.yield(try await feed.load())
                    for await _ in feed.source.changes() {
                        continuation.yield(try await feed.load())
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
