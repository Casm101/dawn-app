import Foundation

/// A value with the moment and the device of its last edit, so two copies can be merged field by field.
public struct Stamped<Value: Codable & Sendable & Hashable>: Codable, Sendable, Hashable {
    public let value: Value
    public let updatedAt: Date
    public let origin: Replica

    public init(_ value: Value, at updatedAt: Date, by origin: Replica) {
        self.value = value
        self.updatedAt = updatedAt
        self.origin = origin
    }

    /// Keeps the current stamp when the value is unchanged, so an untouched field never looks newer.
    public func setting(_ value: Value, at now: Date, by origin: Replica) -> Stamped {
        value == self.value ? self : Stamped(value, at: now, by: origin)
    }
}
