import SwiftUI

/// Stands in for the Progress views that arrive in a later version.
struct ComingLaterView: View {
    var body: some View {
        ContentUnavailableView(
            String(localized: "progress.later.title", defaultValue: "Coming later"),
            systemImage: "hourglass",
            description: Text(String(localized: "progress.later.body", defaultValue: "This view arrives in a later version of Dawn."))
        )
    }
}
