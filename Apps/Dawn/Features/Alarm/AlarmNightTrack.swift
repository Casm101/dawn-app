import DawnCore
import DawnUI
import SwiftUI

/// The night before the alarm on a track: bedtime, the wake zone, the smart alarm's window ending at
/// the alarm, and the alarm marker, which can be dragged in `Tuning.Alarm.dragStep` steps.
struct AlarmNightTrack: View {
    let preview: AlarmSleepPreview
    /// Where the marker may go and still mean this night.
    let range: ClosedRange<Date>
    /// Called with each new time while the marker is dragged.
    let move: (Date) -> Void
    @State private var scale: TrackScale?
    /// Where the alarm was when the drag began, so the marker follows the finger from there.
    @GestureState private var dragStart: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            // The marker rides above the bar, with a line down to the alarm, so it never hides the bands.
            GeometryReader { geometry in
                let width = geometry.size.width
                VStack(alignment: .leading, spacing: 0) {
                    marker(width: width)
                    ZStack(alignment: .leading) {
                        Capsule().fill(DawnColor.card)
                        band(preview.wakeZone, color: DawnColor.wakeZone, width: width)
                        band(preview.window, color: DawnColor.wakeWindow, width: width)
                        Rectangle().fill(DawnColor.accent)
                            .frame(width: DawnSize.alarmLine)
                            .offset(x: x(preview.ring, width) - DawnSize.alarmLine / 2)
                    }
                    .frame(height: DawnSize.editBar)
                }
            }
            .frame(height: DawnSize.editHandle + DawnSize.editBar)
            HStack {
                Text(AlarmPreviewText.bedtime(preview.bedtime))
                Spacer()
                Text(AlarmPreviewText.wakeZone(preview.wakeZone))
            }
            .font(DawnFont.caption)
            .foregroundStyle(DawnColor.secondaryText)
        }
        .onAppear { fit() }
        // Held still under a finger, and fitted to the night again once it lifts or the time
        // changes some other way, such as the wheel or the repeat days.
        .onChange(of: preview) { if dragStart == nil { fit() } }
        .onChange(of: dragStart) { _, start in if start == nil { fit() } }
    }

    private func band(_ interval: DateInterval, color: Color, width: CGFloat) -> some View {
        let from = x(interval.start, width), to = x(interval.end, width)
        return RoundedRectangle(cornerRadius: DawnRadius.chip)
            .fill(color)
            .frame(width: max(DawnSize.minimumBar, to - from), height: DawnSize.editBar)
            .offset(x: from)
            .accessibilityHidden(true)
    }

    private func marker(width: CGFloat) -> some View {
        Image(systemName: "alarm.fill")
            .font(DawnFont.caption.weight(.semibold))
            .foregroundStyle(DawnColor.onAccent)
            .frame(width: DawnSize.editHandle, height: DawnSize.editHandle)
            .background(DawnColor.accent, in: Circle())
            .offset(x: x(preview.ring, width) - DawnSize.editHandle / 2)
            .gesture(DragGesture(minimumDistance: 0)
                .updating($dragStart) { _, state, _ in if state == nil { state = preview.ring } }
                .onChanged { value in
                    // Measured from where the finger left the slop, so the first step is one step.
                    let travel = value.translation.width
                    guard let scale, abs(travel) > DawnSize.pressSlop else { return }
                    let distance = travel - (travel > 0 ? DawnSize.pressSlop : -DawnSize.pressSlop)
                    let start = dragStart ?? preview.ring
                    step(to: scale.date(scale.x(start, width: width) + distance, width: width))
                })
            .accessibilityElement()
            .accessibilityIdentifier("alarm-marker")
            .accessibilityLabel(AlarmPreviewText.marker(preview.ring))
            .accessibilityAdjustableAction { direction in
                step(to: preview.ring.addingTimeInterval(direction == .increment ? Tuning.Alarm.dragStep : -Tuning.Alarm.dragStep))
            }
    }

    /// Moves the alarm to `target`, on a step and within `range`, if that changes it.
    private func step(to target: Date) {
        let moved = min(max(AlarmSleepPreview.snap(target), range.lowerBound), range.upperBound)
        if moved != preview.ring { move(moved) }
    }

    /// Fits the track to the night, from `Tuning.Alarm.trackMargin` before bed to as long after the
    /// zone or the alarm.
    private func fit() {
        let start = min(preview.bedtime, preview.window.start).addingTimeInterval(-Tuning.Alarm.trackMargin)
        let end = max(preview.wakeZone.end, preview.ring).addingTimeInterval(Tuning.Alarm.trackMargin)
        scale = TrackScale(span: DateInterval(start: start, end: end))
    }

    private func x(_ moment: Date, _ width: CGFloat) -> CGFloat {
        CGFloat(scale?.x(moment, width: width) ?? 0)
    }
}
