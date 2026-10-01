import DawnCore
import Foundation

/// The device's own copy of the alarm document, as the sync engine sees it.
@MainActor
public protocol SyncedAlarmStore: AnyObject {
    var document: AlarmDocument { get }
    /// Bumps the revision so the copy is delivered even if unchanged, saves it, and returns it.
    func documentForSending(at now: Date) -> AlarmDocument
    /// Takes a merged document from sync: saves it and applies what changed. Returns true when the
    /// store had to change it further, so the result must go back to the other device.
    func applyRemote(_ document: AlarmDocument, at now: Date) async -> Bool
}
