import DawnCore
import Foundation
import Observation

/// How the user rated their nights, saved on the phone.
@Observable
final class RatingStore {
    private(set) var ratings = NightRatings()
    /// True when the saved ratings could not be read; the file is then never written over.
    private(set) var isReadOnly = false
    private(set) var saveFailed = false
    var isUnsaved: Bool { isReadOnly || saveFailed }
    private let file: JSONFile<NightRatings>

    init(file: JSONFile<NightRatings>) {
        self.file = file
        do {
            ratings = try file.read() ?? NightRatings()
        } catch {
            isReadOnly = true
        }
    }

    func rate(_ day: CalendarDay, _ score: Int) {
        ratings.rate(day, score)
        guard !isReadOnly else { return }
        do {
            try file.write(ratings)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
