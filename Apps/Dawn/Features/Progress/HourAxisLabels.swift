import DawnCore
import DawnUI
import SwiftUI

/// Clock times down the side of the Sleep Times chart, every two hours.
struct HourAxisLabels: View {
    let axis: NightAxis

    var body: some View {
        VStack(spacing: DawnSpacing.xs) {
            Text(verbatim: " ").font(DawnFont.caption)
            GeometryReader { proxy in
                ForEach(hours, id: \.self) { hour in
                    Text(NightText.clock(axisValue: hour))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                        .monospacedDigit()
                        .fixedSize()
                        .position(x: proxy.size.width / 2, y: (hour - axis.lower) / axis.span * proxy.size.height)
                }
            }
            .frame(height: DawnSize.chartHeight)
        }
        .frame(width: DawnSize.axisLabels)
        .accessibilityHidden(true)
    }

    private var hours: [Double] {
        stride(from: axis.lower.rounded(.up), through: axis.upper, by: 2).map { $0 }
    }
}
