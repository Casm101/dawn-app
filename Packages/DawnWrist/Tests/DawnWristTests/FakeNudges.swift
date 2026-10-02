import DawnCore
import Foundation
@testable import DawnWrist

/// Remembers the last reminder and card it was asked for. With `widgetHangs`, handing over the
/// card's relevance never returns, as on the simulator.
actor FakeNudges: WakeNudging {
    let widgetHangs: Bool
    /// Nil until asked; then every reminder booked.
    private(set) var reminders: [Date]?
    /// The first reminder booked, as `.some(nil)` when asked for none.
    var reminder: Date?? { reminders.map(\.first) }
    private(set) var widget: DateInterval??
    private(set) var authorizations = 0

    init(widgetHangs: Bool = false) {
        self.widgetHangs = widgetHangs
    }

    func remind(at dates: [Date]) async { reminders = dates }
    func offerWidget(during interval: DateInterval?) async {
        if widgetHangs { try? await Task.sleep(for: .seconds(3600)) }
        widget = .some(interval)
    }
    func authorize() async { authorizations += 1 }
}
