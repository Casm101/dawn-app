import DawnCore
import DawnUI
import SwiftUI

/// The night before the alarm on a track: bedtime, the wake zone, the smart alarm's window ending at
/// the alarm, and the alarm marker, which can be dragged in `Tuning.Alarm.dragStep` steps.
struct AlarmNightTrack: View {
    let preview: AlarmSleepPreview
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
                            .frame(width: DawnSize.nowLine)
                            .offset(x: x(preview.ring, width) - DawnSize.nowLine / 2)
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
        .onAppear { widen() }
        .onChange(of: preview) { widen() }
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
                    guard let scale, abs(value.translation.width) > DawnSize.pressSlop else { return }
                    let start = dragStart ?? preview.ring
                    let moved = AlarmSleepPreview.snap(scale.date(scale.x(start, width: width) + value.translation.width, width: width))
                    if moved != preview.ring { move(moved) }
                })
            .accessibilityElement()
            .accessibilityIdentifier("alarm-marker")
            .accessibilityLabel(AlarmPreviewText.marker(preview.ring))
            .accessibilityAdjustableAction { direction in
                let step = direction == .increment ? Tuning.Alarm.dragStep : -Tuning.Alarm.dragStep
                move(preview.ring.addingTimeInterval(step))
            }
    }

    /// Takes in the night, from an hour before bed to an hour after the zone or the alarm, and
    /// never shrinks while the marker moves.
    private func widen() {
        let end = max(preview.wakeZone.end, preview.ring).addingTimeInterval(Tuning.Alarm.trackMargin)
        let night = DateInterval(start: min(preview.bedtime, preview.window.start).addingTimeInterval(-Tuning.Alarm.trackMargin), end: end)
        if scale == nil { scale = TrackScale(span: night) } else { scale?.widen(to: night) }
    }

    private func x(_ moment: Date, _ width: CGFloat) -> CGFloat {
        CGFloat(scale?.x(moment, width: width) ?? 0)
    }
}
