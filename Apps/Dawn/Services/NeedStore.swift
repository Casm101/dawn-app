import DawnCore
import Foundation
import Observation

/// The user's sleep need, saved on the phone. Learns from alarm-free nights unless set by hand.
@Observable
final class NeedStore {
    private(set) var need = SleepNeed()
    /// True when the saved need could not be read; the file is then never written over.
    private(set) var isReadOnly = false
    private(set) var saveFailed = false
    private let file: JSONFile<SleepNeed>

    init(file: JSONFile<SleepNeed>) {
        self.file = file
        do {
            need = try file.read() ?? SleepNeed()
        } catch {
            isReadOnly = true
        }
    }

    func set(_ value: TimeInterval) {
        need.set(value)
        save()
    }

    func resumeLearning() {
        need.resumeLearning()
        save()
    }

    /// Moves need toward recent alarm-free nights, within the weekly limit.
    func learn(from sessions: [SleepSession], alarms: [AlarmDefinition], now: Date = Date()) {
        let before = need
        need.learn(
            fromFreeNights: AlarmFreeNights.asleep(in: sessions, alarms: alarms, calendar: .current), now: now
        )
        if need != before { save() }
    }

    private func save() {
        guard !isReadOnly else { return }
        do {
            try file.write(need)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
