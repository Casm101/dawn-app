import DawnCore
import DawnUI
import SwiftUI

/// Hour labels and hour and quarter-hour ticks, drawn in one Canvas so scrolling stays cheap.
struct TimelineGrid: View {
    let window: TimelineWindow

    var body: some View {
        Canvas { context, size in
            for tick in window.ticks(calendar: .current) {
                let y = window.position(tick.date) * size.height
                let length = tick.isHour ? DawnSize.hourTick : DawnSize.quarterTick
                var line = Path()
                line.move(to: CGPoint(x: size.width - length, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(DawnColor.secondaryText), style: DawnStroke.tick)
                if tick.isHour {
                    let label = Text(tick.date.formatted(.dateTime.hour(.twoDigits(amPM: .abbreviated))))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                    let inset = DawnSpacing.sm
                    context.draw(label, at: CGPoint(x: 0, y: min(max(y, inset), size.height - inset)), anchor: .leading)
                }
            }
        }
        .accessibilityHidden(true)
    }
}
