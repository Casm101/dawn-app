/// How far the two copies have got: the newest revision this device sent as a change, the newest the
/// other device said arrived, and the newest of the other device's revisions merged here. Saved, so a
/// relaunched device still knows whether it is waiting and which copies it has already merged.
public struct SyncProgress: Codable, Sendable, Equatable {
    public var sent = 0
    public var acknowledged = 0
    public var received = 0

    public init() {}
}
