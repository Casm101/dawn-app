import DawnCore
import SwiftUI

/// Colour roles. The only file allowed to name a colour; views use these roles.
public nonisolated enum DawnColor {
    /// The app's single accent, taken from the app's asset catalogue.
    public static let accent = Color.accentColor
    /// Text and symbols drawn on top of the accent.
    public static let onAccent = Color.white
    /// The line marking the current time on a timeline.
    public static let nowLine = Color(red: 0.98, green: 0.36, blue: 0.42)
    /// Something that needs attention, such as an alarm that could not be set.
    public static let warning = Color.orange
    public static let card = Color(white: 0.5, opacity: 0.12)
    public static let secondaryText = Color.secondary

    public static let bandOkay = Color(red: 0.30, green: 0.75, blue: 0.48)
    public static let bandBuilding = Color(red: 0.96, green: 0.62, blue: 0.20)
    public static let bandHigh = Color(red: 0.93, green: 0.33, blue: 0.45)

    public static let awake = Color(red: 0.97, green: 0.58, blue: 0.24)
    public static let rem = Color(red: 0.36, green: 0.72, blue: 0.98)
    public static let core = Color(red: 0.55, green: 0.42, blue: 0.95)
    public static let deep = Color(red: 0.33, green: 0.20, blue: 0.70)
    public static let unspecified = Color(red: 0.62, green: 0.58, blue: 0.78)

    public static let grogginess = Color(red: 0.62, green: 0.66, blue: 0.74)
    public static let peak = Color(red: 0.98, green: 0.74, blue: 0.22)
    public static let dip = Color(red: 0.42, green: 0.62, blue: 0.86)
    public static let windDown = Color(red: 0.66, green: 0.50, blue: 0.88)
    public static let melatonin = Color(red: 0.40, green: 0.30, blue: 0.72)
    /// The predicted energy line on the timeline.
    public static let energyLine = Color(red: 0.98, green: 0.62, blue: 0.20)

    public static func phase(_ phase: EnergyPhase) -> Color {
        switch phase {
        case .grogginess: grogginess
        case .morningPeak, .eveningPeak: peak
        case .afternoonDip: dip
        case .windDown: windDown
        case .melatoninWindow: melatonin
        }
    }

    /// The phase's colour faded for a band behind other content.
    public static func phaseTint(_ phase: EnergyPhase) -> Color { self.phase(phase).opacity(0.16) }

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
