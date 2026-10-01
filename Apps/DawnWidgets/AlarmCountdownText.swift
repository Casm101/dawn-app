import AlarmKit
import SwiftUI

/// Minutes and seconds until a snoozed alarm rings again; empty otherwise.
struct AlarmCountdownText: View {
    let state: AlarmPresentationState

    var body: some View {
        if case .countdown(let countdown) = state.mode {
            Text(timerInterval: Date.now...countdown.fireDate, countsDown: true)
                .monospacedDigit()
        }
    }
}
