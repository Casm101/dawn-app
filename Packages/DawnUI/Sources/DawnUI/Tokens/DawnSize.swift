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
    /// The width of a chart's hour labels.
    public static let axisLabels: CGFloat = 28
    /// The share of a column a bar fills.
    public static let barFill: CGFloat = 0.55
}
