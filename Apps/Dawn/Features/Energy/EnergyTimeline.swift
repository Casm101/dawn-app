import DawnCore
import DawnUI
import SwiftUI

/// The timeline itself: hour grid, the day's phases with the energy line over them, sleep cards, the
/// stage rail and the now line, one hour to `DawnSize.hourHeight`.
struct EnergyTimeline: View {
    static let nowAnchorID = "now"

    let window: TimelineWindow
    let sessions: [SleepSession]
    let schedule: EnergySchedule
    let now: Date

    var body: some View {
        let height = DawnSize.hourHeight * window.end.timeIntervalSince(window.start) / 3600
        let runs = StageRun.runs(of: sessions, in: window.interval)
        HStack(alignment: .top, spacing: DawnSpacing.sm) {
            TimelineGrid(window: window)
                .frame(width: DawnSize.timelineGutter)
            ZStack(alignment: .topLeading) {
                ForEach(schedule.phases.filter { $0.end > window.start && $0.start < window.end }) { span in
                    PhaseBand(span: span, window: window, height: height)
                }
                EnergyCurveLine(curve: schedule.curve, window: window)
                ForEach(window.segments(of: sessions)) { segment in
                    SleepSegmentCard(segment: segment, window: window, height: height)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            if !runs.isEmpty {
                StageRail(runs: runs, window: window)
                    .frame(width: DawnSize.railWidth)
            }
        }
        .frame(height: height)
        .overlay(alignment: .topLeading) {
            NowMarker(now: now)
                .offset(y: window.position(now) * height)
        }
        .background(alignment: .top) {
            // A real view at now's height, because scrolling targets layout frames, not offsets.
            VStack(spacing: 0) {
                Color.clear.frame(height: window.position(now) * height)
                Color.clear.frame(height: DawnSize.hairline).id(Self.nowAnchorID)
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, DawnSpacing.lg)
    }
}
