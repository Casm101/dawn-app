import DawnCore
import Foundation
@testable import DawnWrist

/// Remembers the last reminder and card it was asked for. With `widgetHangs`, handing over the
/// card's relevance never returns, as on the simulator; `widgetDelay` makes it slow, and `widgets`
/// records every hand-over in the order it landed.
actor FakeNudges: WakeNudging {
    let widgetHangs: Bool
    let widgetDelay: Duration
    private(set) var widgets: [DateInterval?] = []
    /// Nil until asked; then every reminder booked.
    private(set) var reminders: [Date]?
    /// The first reminder booked, as `.some(nil)` when asked for none.
    var reminder: Date?? { reminders.map(\.first) }
    private(set) var widget: DateInterval??
    private(set) var authorizations = 0

    init(widgetHangs: Bool = false, widgetDelay: Duration = .zero) {
        self.widgetHangs = widgetHangs
        self.widgetDelay = widgetDelay
    }

    func remind(at dates: [Date]) async { reminders = dates }
    func offerWidget(during interval: DateInterval?) async {
        if widgetHangs { try? await Task.sleep(for: .seconds(3600)) }
        try? await Task.sleep(for: widgetDelay)
        widget = .some(interval)
        widgets.append(interval)
    }
    func authorize() async { authorizations += 1 }
}
