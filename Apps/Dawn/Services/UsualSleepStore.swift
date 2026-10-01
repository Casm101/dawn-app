import DawnCore
import Foundation
import Observation

/// The bedtime and wake time the user gave, saved on the phone. The schedule stands on these until
/// Health has three recent nights.
@Observable
final class UsualSleepStore {
    private(set) var usual = UsualSleep()
    /// True when the saved times could not be read; the file is then never written over.
    private(set) var isReadOnly = false
    private(set) var saveFailed = false
    private let file: JSONFile<UsualSleep>

    init(file: JSONFile<UsualSleep>) {
        self.file = file
        do {
            usual = try file.read() ?? UsualSleep()
        } catch {
            isReadOnly = true
        }
    }

    func set(_ usual: UsualSleep) {
        self.usual = usual
        guard !isReadOnly else { return }
        do {
            try file.write(usual)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
