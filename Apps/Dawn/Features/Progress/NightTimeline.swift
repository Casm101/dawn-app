import DawnCore
import Foundation

/// A night's segments and the awake gaps between them, in time order.
enum NightTimeline {
    struct Entry: Identifiable, Hashable {
        let start: Date
        let end: Date
        let isAwake: Bool
        var id: Date { start }
    }

    static func entries(for slot: NightSlot) -> [Entry] {
        slot.nights.flatMap { night in
            let asleep = night.segments.map { Entry(start: $0.start, end: $0.end, isAwake: false) }
            let awake = night.awakeGaps.map { Entry(start: $0.start, end: $0.end, isAwake: true) }
            return (asleep + awake).sorted { $0.start < $1.start }
        }
    }
}
