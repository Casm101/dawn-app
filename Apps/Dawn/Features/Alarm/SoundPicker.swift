import DawnCore
import DawnUI
import SwiftUI

/// The bundled sounds; choosing one selects it and plays it.
struct SoundPicker: View {
    @Binding var selection: AlarmSound
    let preview: SoundPreview

    var body: some View {
        ForEach(AlarmSound.allCases, id: \.self) { sound in
            Button {
                selection = sound
                preview.play(sound)
            } label: {
                HStack {
                    Text(AlarmText.sound(sound))
                    Spacer()
                    if preview.playing == sound {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(DawnColor.accent)
                            .accessibilityLabel(String(localized: "alarm.sound.playing", defaultValue: "Playing"))
                    }
                    if selection == sound {
                        Image(systemName: "checkmark")
                            .foregroundStyle(DawnColor.accent)
                    }
                }
            }
            .foregroundStyle(.primary)
            .accessibilityAddTraits(selection == sound ? .isSelected : [])
        }
    }
}
