import AlarmKit
import DawnAlarmKit
import DawnUI
import SwiftUI

/// The alarm's title and, while snoozing, the time left.
struct AlarmActivityView: View {
    let attributes: AlarmAttributes<DawnAlarmMetadata>
    let state: AlarmPresentationState

    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(DawnFont.title)
            } icon: {
                Image(systemName: "alarm")
            }
            Spacer()
            AlarmCountdownText(state: state)
                .font(DawnFont.metric)
        }
        .foregroundStyle(attributes.tintColor)
    }

    private var title: LocalizedStringResource {
        if case .countdown = state.mode, let countdown = attributes.presentation.countdown {
            return countdown.title
        }
        return attributes.presentation.alert.title
    }
}
