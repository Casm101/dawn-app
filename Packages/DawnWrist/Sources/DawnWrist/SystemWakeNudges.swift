#if os(watchOS)
import Foundation

/// The real reminder and Smart Stack card: a local notification and a relevant-intent donation.
public struct SystemWakeNudges: WakeNudging {
    private let title: String
    private let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }

    public func remind(at date: Date?) async {
        await BedtimeReminder.schedule(at: date, title: title, body: body)
    }

    public func offerWidget(during interval: DateInterval?) async {
        await WakeRelevance.update(during: interval)
    }
}
#endif
