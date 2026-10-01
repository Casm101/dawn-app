import DawnCore
import DawnUI
import SwiftUI

/// Hour labels and hour and quarter-hour ticks, drawn in one Canvas so scrolling stays cheap.
struct TimelineGrid: View {
    let window: TimelineWindow

    var body: some View {
        Canvas { context, size in
            let total = window.end.timeIntervalSince(window.start)
            var tick = window.start
            while tick <= window.end {
                let y = tick.timeIntervalSince(window.start) / total * size.height
                let isHour = Calendar.current.component(.minute, from: tick) == 0
                let length = isHour ? DawnSize.hourTick : DawnSize.quarterTick
                var line = Path()
                line.move(to: CGPoint(x: size.width - length, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(DawnColor.secondaryText), lineWidth: 1)
                if isHour {
                    let label = Text(tick.formatted(.dateTime.hour(.twoDigits(amPM: .abbreviated))))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                    let inset = DawnSpacing.sm
                    context.draw(label, at: CGPoint(x: 0, y: min(max(y, inset), size.height - inset)), anchor: .leading)
                }
                tick = tick.addingTimeInterval(Tuning.Timeline.tickInterval)
            }
        }
        .accessibilityHidden(true)
    }
}
