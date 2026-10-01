import SwiftUI

/// Line styles. No literal stroke styles outside this file.
public nonisolated enum DawnStroke {
    /// The outline of something that has not happened yet, such as tonight before any sleep.
    public static let placeholder = StrokeStyle(lineWidth: 1.5, dash: [4, 3])
    /// A tick on a timeline.
    public static let tick = StrokeStyle(lineWidth: 1)
}
