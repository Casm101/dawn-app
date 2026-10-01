import DawnCore
import DawnHealth
import Foundation
import Observation

/// Recent sleep as Apple Health reports it. Views read it; only Health writes it.
@Observable
final class SleepStore {
    private(set) var access: HealthAccessState = .notDetermined
    private(set) var sessions: [SleepSession] = []
    /// False until the first read from Health has finished, so an empty state is never shown early.
    private(set) var hasLoaded = false

    private let healthAccess: any HealthAccess
    private let feed: SleepSessionFeed

    init(access: any HealthAccess, feed: SleepSessionFeed) {
        healthAccess = access
        self.feed = feed
    }

    var recent: RecentSleep { RecentSleep(sessions: sessions, now: Date()) }

    func refreshAccess() async {
        access = await healthAccess.state()
    }

    /// Shows the Health prompt. Health shows it once; later calls return the stored answer.
    func connect() async {
        access = await healthAccess.requestSleepRead()
    }

    /// Follows Health while access is granted, until the calling task is cancelled.
    func follow() async {
        guard access == .granted else { return }
        do {
            for try await sessions in feed.updates() {
                self.sessions = sessions
                hasLoaded = true
            }
        } catch {
            hasLoaded = true
        }
    }

    func reload() async {
        guard access == .granted, let sessions = try? await feed.load() else { return }
        self.sessions = sessions
        hasLoaded = true
    }
}
