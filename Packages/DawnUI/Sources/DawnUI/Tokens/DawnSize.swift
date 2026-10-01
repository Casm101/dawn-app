import Foundation

/// Fixed sizes. No literal frame sizes outside this file.
public nonisolated enum DawnSize {
    /// The smallest comfortable tap target.
    public static let tapTarget: CGFloat = 44
    /// A round chip holding a single letter.
    public static let chip: CGFloat = 36
    /// The plot height of the Sleep Times chart.
    public static let chartHeight: CGFloat = 280
    /// Room under a chart page for its labels and the page dots.
    public static let chartFooter: CGFloat = 72
    /// The least height a bar is drawn with, so a very short segment stays visible.
    public static let minimumBar: CGFloat = 3
    /// One hour of the Energy timeline.
    public static let hourHeight: CGFloat = 64
    /// The column of hour labels down the timeline's left edge.
    public static let timelineGutter: CGFloat = 52
    /// The stage rail down the timeline's right edge.
    public static let railWidth: CGFloat = 44
    /// Hour and quarter-hour tick lengths on the timeline.
    public static let hourTick: CGFloat = 12
    public static let quarterTick: CGFloat = 5
    /// The least height a sleep card needs to show its start and end times.
    public static let cardWithTimes: CGFloat = 44
    /// The thinnest line or mark that still shows.
    public static let hairline: CGFloat = 1
    /// The least height a sleep card needs for its times on one line.
    public static let cardWithRange: CGFloat = 16
    /// The thickness of the now line.
    public static let nowLine: CGFloat = 2
    /// The width of a chart's hour labels.
    public static let axisLabels: CGFloat = 28
    /// The share of a column a bar fills.
    public static let barFill: CGFloat = 0.55
}
