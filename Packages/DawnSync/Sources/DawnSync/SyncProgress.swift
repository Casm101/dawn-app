/// How far this device's changes have got: the newest revision it sent as a change, and the newest
/// the other device said arrived. Saved, so a relaunched device still knows it is waiting.
public struct SyncProgress: Codable, Sendable, Equatable {
    public var sent = 0
    public var acknowledged = 0

    public init() {}
}
