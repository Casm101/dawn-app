import Foundation

/// The words on the system alarm, supplied by the app so they live in its string catalogue.
public struct AlarmAlertCopy: Sendable {
    public let title: LocalizedStringResource
    public let stop: LocalizedStringResource
    public let snooze: LocalizedStringResource
    public let snoozing: LocalizedStringResource

    public init(
        title: LocalizedStringResource,
        stop: LocalizedStringResource,
        snooze: LocalizedStringResource,
        snoozing: LocalizedStringResource
    ) {
        self.title = title
        self.stop = stop
        self.snooze = snooze
        self.snoozing = snoozing
    }
}
