import DawnCore
import Foundation
import SwiftUI

/// How each sleep-debt band is named and coloured, everywhere it appears.
public nonisolated enum DebtBandStyle {
    public static func label(_ band: DebtBand, locale: Locale = .current) -> String {
        switch band {
        case .okay: String(localized: "debt.band.okay", defaultValue: "Okay", bundle: .module, locale: locale)
        case .building: String(localized: "debt.band.building", defaultValue: "Building", bundle: .module, locale: locale)
        case .high: String(localized: "debt.band.high", defaultValue: "High", bundle: .module, locale: locale)
        }
    }

    public static func color(_ band: DebtBand) -> Color {
        switch band {
        case .okay: DawnColor.bandOkay
        case .building: DawnColor.bandBuilding
        case .high: DawnColor.bandHigh
        }
    }
}
