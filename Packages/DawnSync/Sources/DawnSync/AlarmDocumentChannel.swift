import DawnCore

/// How one device's copy of the alarm document reaches the other. WatchConnectivity sits behind it
/// on the phone and the Watch; tests use a fake.
public protocol AlarmDocumentChannel: Sendable {
    /// Waits until the channel can send and receive.
    func activate() async
    /// Sends the latest document; only the newest one sent is ever delivered.
    func publish(_ document: AlarmDocument) throws
    /// Tells the other device which of its revisions arrived. Queued until it can be delivered.
    func acknowledge(_ revision: Int)
    /// True when there is another device with Dawn on it to wait for.
    func counterpartAvailable() async -> Bool
    /// Documents from the other device, newest last.
    var documents: AsyncStream<AlarmDocument> { get }
    /// Revisions of this device's documents that the other device has received.
    var acknowledgements: AsyncStream<Int> { get }
}
