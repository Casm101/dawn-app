import DawnCore
import SwiftUI

/// Colour roles. The only file allowed to name a colour; views use these roles.
public nonisolated enum DawnColor {
    /// The app's single accent, taken from the app's asset catalogue.
    public static let accent = Color.accentColor
    public static let card = Color(white: 0.5, opacity: 0.12)
    public static let secondaryText = Color.secondary

    public static let awake = Color(red: 0.97, green: 0.58, blue: 0.24)
    public static let rem = Color(red: 0.36, green: 0.72, blue: 0.98)
    public static let core = Color(red: 0.55, green: 0.42, blue: 0.95)
    public static let deep = Color(red: 0.33, green: 0.20, blue: 0.70)
    public static let unspecified = Color(red: 0.62, green: 0.58, blue: 0.78)

    public static func stage(_ stage: SleepStage) -> Color {
        switch stage {
        case .awake: awake
        case .rem: rem
        case .core: core
        case .deep: deep
        case .unspecified: unspecified
        }
    }
}
