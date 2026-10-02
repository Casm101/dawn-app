import DawnCore
import Foundation
@testable import DawnWrist

/// Remembers the last reminder and card it was asked for.
actor FakeNudges: WakeNudging {
    private(set) var reminder: Date??
    private(set) var widget: DateInterval??
    private(set) var authorizations = 0

    func remind(at date: Date?) async { reminder = .some(date) }
    func offerWidget(during interval: DateInterval?) async { widget = .some(interval) }
    func authorize() async { authorizations += 1 }
}
