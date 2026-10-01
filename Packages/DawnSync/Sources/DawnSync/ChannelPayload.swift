import DawnCore
import Foundation

/// What travels between the devices in one WatchConnectivity dictionary: a document, an
/// acknowledgement, or a wake window's outcome, each under its own key.
public struct ChannelPayload: Sendable, Equatable {
    public var document: AlarmDocument?
    public var acknowledged: Int?
    public var outcome: WakeOutcome?

    public init(document: AlarmDocument? = nil, acknowledged: Int? = nil, outcome: WakeOutcome? = nil) {
        self.document = document
        self.acknowledged = acknowledged
        self.outcome = outcome
    }

    /// Reads whatever the dictionary holds; anything unreadable is left out.
    public init(_ dictionary: [String: Any]) {
        self.init(
            document: (dictionary[Keys.document] as? Data).flatMap { try? JSONDecoder().decode(AlarmDocument.self, from: $0) },
            acknowledged: dictionary[Keys.acknowledged] as? Int,
            outcome: (dictionary[Keys.outcome] as? Data).flatMap { try? JSONDecoder().decode(WakeOutcome.self, from: $0) }
        )
    }

    public var dictionary: [String: Any] {
        var result: [String: Any] = [:]
        if let document, let data = try? JSONEncoder().encode(document) { result[Keys.document] = data }
        if let acknowledged { result[Keys.acknowledged] = acknowledged }
        if let outcome, let data = try? JSONEncoder().encode(outcome) { result[Keys.outcome] = data }
        return result
    }

    private enum Keys {
        static let document = "document"
        static let acknowledged = "acknowledged"
        static let outcome = "outcome"
    }
}
