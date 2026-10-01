import AVFoundation
import DawnCore
import Observation

/// Plays a bundled alarm sound so the user can hear it before choosing it.
@Observable
final class SoundPreview {
    private(set) var playing: AlarmSound?
    @ObservationIgnored private var player: AVAudioPlayer?

    func play(_ sound: AlarmSound) {
        stop()
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: nil),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.play()
        self.player = player
        playing = sound
    }

    func stop() {
        player?.stop()
        player = nil
        playing = nil
    }
}
