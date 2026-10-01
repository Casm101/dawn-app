import Foundation

/// Lays the day's phases end to end from waking to the end of the melatonin window, using the curve's
/// own dip and peaks where it has them and the priors where it is flat.
public enum PhaseLayout {
    private typealias T = Tuning.Energy

    public static func phases(curve: EnergyCurve, wake: Date, bedtime: Date) -> [PhaseSpan] {
        let anchors = MelatoninAnchors(bedtime: bedtime)
        let groggy = wake.addingTimeInterval(T.grogginess.clamped(AlertnessModel.inertiaLasts(until: T.grogginessEndsAbove)))
        let priorStart = wake.addingTimeInterval(T.dipPrior.lowerBound)
        let priorEnd = wake.addingTimeInterval(T.dipPrior.upperBound)
        let half = (T.dipPrior.upperBound - T.dipPrior.lowerBound) / 2
        let search = DateInterval(start: priorStart.addingTimeInterval(-T.searchSlack), end: priorEnd.addingTimeInterval(T.searchSlack))
        let dip = PhaseFinder.lowest(in: curve, within: search)
        let centre = dip ?? priorStart.addingTimeInterval(half)
        var dipStart = dip?.addingTimeInterval(-half) ?? priorStart
        var dipEnd = dip?.addingTimeInterval(half) ?? priorEnd
        // A peak the curve does have stays inside its own band: the dip gives way halfway to it.
        if let peak = between(groggy, centre).flatMap({ PhaseFinder.highest(in: curve, within: $0) }), peak >= dipStart {
            dipStart = midpoint(peak, centre)
        }
        if let peak = between(centre, anchors.windDownStart).flatMap({ PhaseFinder.highest(in: curve, within: $0) }), peak <= dipEnd {
            dipEnd = midpoint(centre, peak)
        }
        let edges = ordered([
            wake, groggy, min(dipStart, anchors.windDownStart), min(dipEnd, anchors.windDownStart),
            anchors.windDownStart, anchors.windowStart, anchors.windowEnd,
        ])
        return zip(EnergyPhase.allCases, zip(edges, edges.dropFirst())).compactMap { phase, edge in
            edge.0 < edge.1 ? PhaseSpan(phase: phase, start: edge.0, end: edge.1) : nil
        }
    }

    /// Each edge no earlier than the one before it, so phases never overlap.
    private static func ordered(_ edges: [Date]) -> [Date] {
        edges.reduce(into: []) { result, edge in result.append(max(edge, result.last ?? edge)) }
    }

    private static func between(_ start: Date, _ end: Date) -> DateInterval? {
        start < end ? DateInterval(start: start, end: end) : nil
    }

    private static func midpoint(_ a: Date, _ b: Date) -> Date {
        a.addingTimeInterval(b.timeIntervalSince(a) / 2)
    }
}
