import DawnCore
import Foundation
@testable import DawnWrist

/// Remembers the last reminder and card it was asked for.
actor FakeNudges: WakeNudging {
    /// Nil until asked; then every reminder booked.
    private(set) var reminders: [Date]?
    /// The first reminder booked, as `.some(nil)` when asked for none.
    var reminder: Date?? { reminders.map(\.first) }
    private(set) var widget: DateInterval??
    private(set) var authorizations = 0

    func remind(at dates: [Date]) async { reminders = dates }
    func offerWidget(during interval: DateInterval?) async { widget = .some(interval) }
    func authorize() async { authorizations += 1 }
}
