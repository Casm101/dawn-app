import DawnCore
import Foundation

/// One ring of an alarm stood down because the Watch woke the wearer before it.
public struct BackstopSkip: Codable, Hashable, Sendable {
    /// The ring that must not sound.
    public let ring: Date
    public let weekday: Weekday
    /// The one-off alarm standing in for the same weekday a week later, for a repeating alarm.
    public let fixedID: UUID?

    public init(ring: Date, weekday: Weekday, fixedID: UUID?) {
        self.ring = ring
        self.weekday = weekday
        self.fixedID = fixedID
    }

    /// The system id of the stand-in for an alarm at a moment: the alarm's id with the moment's
    /// minute folded into its last bytes. Worked out again from any one-off system alarm, it tells a
    /// lost stand-in apart from every other exact-moment alarm.
    public static func standInID(for alarmID: UUID, at date: Date) -> UUID {
        var bytes = alarmID.uuid
        let minute = UInt64(bitPattern: Int64((date.timeIntervalSinceReferenceDate / 60).rounded()))
        withUnsafeMutableBytes(of: &bytes) { raw in
            for index in 0..<8 { raw[8 + index] ^= UInt8(truncatingIfNeeded: minute >> (8 * index)) }
        }
        return UUID(uuid: bytes)
    }
}
