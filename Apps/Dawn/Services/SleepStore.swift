import DawnCore
import DawnHealth
import Foundation
import Observation

/// Recent sleep as Apple Health reports it, with the user's corrections and added naps laid over it.
/// Views read it; only Health and the user's edits change it.
@Observable
final class SleepStore {
    /// Nil until the first check, so the Health prompt never flashes for someone who already answered it.
    private(set) var access: HealthAccessState?
    /// What Health holds, before any correction.
    private(set) var imported: [SleepSession] = []
    /// False until the first read from Health has finished, so an empty state is never shown early.
    private(set) var hasLoaded = false

    private let healthAccess: any HealthAccess
    private let feed: SleepSessionFeed
    private let edits: SleepEditsStore

    init(access: any HealthAccess, feed: SleepSessionFeed, edits: SleepEditsStore) {
        healthAccess = access
        self.feed = feed
        self.edits = edits
    }

    /// The sessions everything else uses: Health's, corrected, with added naps.
    var sessions: [SleepSession] { edits.edits.apply(to: imported, calendar: .current) }

    var recent: RecentSleep { RecentSleep(sessions: sessions, now: Date()) }

    func refreshAccess() async {
        access = await healthAccess.state()
    }

    /// Shows the Health prompt. Health shows it once; later calls return the stored answer.
    func connect() async {
        access = await healthAccess.requestSleepRead()
    }

    /// Follows Health while access is granted, until the calling task is cancelled. A failed read
    /// keeps what was already shown.
    func follow() async {
        guard access == .granted else { return }
        for await result in feed.updates() {
            if case .success(let sessions) = result { imported = sessions }
            hasLoaded = true
        }
    }

    func reload() async {
        guard access == .granted, let sessions = try? await feed.load() else { return }
        imported = sessions
        hasLoaded = true
    }
}
