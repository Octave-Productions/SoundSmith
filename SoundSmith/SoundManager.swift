import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        preloadSounds()
    }

    private func preloadSounds() {
        let pitches = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        for pitch in pitches {
            if let url = Bundle.main.url(forResource: pitch, withExtension: "wav") {
                audioPlayers[pitch] = try? AVAudioPlayer(contentsOf: url)
                audioPlayers[pitch]?.prepareToPlay()
            }
        }
    }

    func playSound(for pitch: String) {
        audioPlayers[pitch]?.currentTime = 0
        audioPlayers[pitch]?.play()
    }
}

