/// One of the two devices that hold a copy of the alarm document.
public enum Replica: String, Codable, Sendable, Equatable {
    case phone
    case watch

    /// When two edits carry the same timestamp and revision, the phone's edit wins.
    public func winsTie(against other: Replica) -> Bool {
        self == .phone || other == self
    }
}
