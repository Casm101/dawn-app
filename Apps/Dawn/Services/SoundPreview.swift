import AVFoundation
import DawnCore
import Observation

/// Plays a bundled alarm sound so the user can hear it before choosing it, even with the Silent
/// switch on, since that is how most people's phones are at bedtime.
@Observable
final class SoundPreview: NSObject, AVAudioPlayerDelegate {
    private(set) var playing: AlarmSound?
    @ObservationIgnored private var player: AVAudioPlayer?

    func play(_ sound: AlarmSound) {
        stop()
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: nil),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player.delegate = self
        player.play()
        self.player = player
        playing = sound
    }

    func stop() {
        player?.stop()
        player = nil
        finish()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.finish() }
    }

    private func finish() {
        guard playing != nil else { return }
        playing = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
