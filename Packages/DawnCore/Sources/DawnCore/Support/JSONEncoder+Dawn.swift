import Foundation

extension JSONEncoder {
    /// Sorted keys, so a stored document diffs cleanly. Dates keep their full precision, because
    /// the newer of two edit stamps wins a merge even when they are under a second apart.
    static var dawn: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
