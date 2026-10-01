import Foundation

/// A Codable value kept in one JSON file, written atomically.
public struct JSONFile<Value: Codable & Sendable>: Sendable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    /// The stored value, or nil when the file does not exist yet.
    public func read() throws -> Value? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder.dawn.decode(Value.self, from: Data(contentsOf: url))
    }

    public func write(_ value: Value) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try JSONEncoder.dawn.encode(value).write(to: url, options: .atomic)
    }
}
