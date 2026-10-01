import Foundation

extension JSONEncoder {
    /// Dates as ISO 8601 and sorted keys, so a stored document reads and diffs cleanly.
    static var dawn: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
