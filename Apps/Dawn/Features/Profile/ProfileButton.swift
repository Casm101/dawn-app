import SwiftUI

/// The toolbar button that opens Profile.
struct ProfileButton: View {
    @State private var showing = false

    var body: some View {
        Button(String(localized: "profile.open", defaultValue: "Profile"), systemImage: "person.crop.circle") {
            showing = true
        }
        .sheet(isPresented: $showing) { ProfileView() }
    }
}
