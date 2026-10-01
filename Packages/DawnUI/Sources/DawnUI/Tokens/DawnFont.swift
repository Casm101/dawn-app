import SwiftUI

/// The type ramp. Views pick a role, never a size.
public nonisolated enum DawnFont {
    /// The one number that matters on a screen.
    public static let metric = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    public static let title = Font.headline
    public static let body = Font.subheadline
    public static let caption = Font.caption
}
