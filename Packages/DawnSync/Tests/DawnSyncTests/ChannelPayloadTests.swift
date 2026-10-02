import DawnCore
import Foundation
import Testing
@testable import DawnSync

struct ChannelPayloadTests {
    @Test func eachKindOfPayloadSurvivesTheTrip() {
        var document = AlarmDocument()
        document.save(AlarmSettings(time: ClockTime(hour: 7, minute: 0)!), id: UUID(), at: Date(timeIntervalSince1970: 1_790_000_000.25), by: .phone)
        let outcome = WakeOutcome(
            alarmID: UUID(), windowStart: Date(timeIntervalSince1970: 1_790_000_000), windowEnd: Date(timeIntervalSince1970: 1_790_001_800),
            result: .wokeEarly, firedAt: Date(timeIntervalSince1970: 1_790_000_900.5), trigger: .stirring, usedMotion: true, epochs: 30, peakScore: 0.6
        )
        let payload = ChannelPayload(document: document, acknowledged: 7, outcome: outcome)
        #expect(ChannelPayload(payload.dictionary) == payload)
    }

    @Test func somethingUnreadableIsLeftOut() {
        let payload = ChannelPayload(["document": Data("{".utf8), "acknowledged": 3, "outcome": 12])
        #expect(payload == ChannelPayload(acknowledged: 3))
    }
}
