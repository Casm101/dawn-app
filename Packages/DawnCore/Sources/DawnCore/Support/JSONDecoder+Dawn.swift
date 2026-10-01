import Foundation

extension JSONDecoder {
    /// Reads what `JSONEncoder.dawn` writes.
    static var dawn: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
