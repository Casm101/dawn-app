// Synthesises Dawn's alarm sounds. Each clip starts at a quarter of full volume and reaches full
// volume by 8 seconds, which is the gentle-wake ramp, then holds it; the system loops the clip, so
// most of every pass is loud. Clips stay under AlarmKit's 30-second limit.
//
// The clips are generated from code in this file, contain no recorded material, and are dedicated
// to the public domain under CC0 1.0 (https://creativecommons.org/publicdomain/zero/1.0/).
//
// Usage: swift Scripts/make-alarm-sounds.swift Apps/Dawn/Resources/Sounds
import AVFoundation
import Foundation
let rate = 22_050.0
let seconds = 28.0
let frames = Int(rate * seconds)

func ramp(_ t: Double) -> Double { let x = min(1, t / 8); return 0.25 + 0.75 * x * x }

func chimes(_ t: Double) -> Double {
    let notes = [523.25, 659.25, 783.99, 1046.5, 783.99, 659.25]
    let step = 0.75
    let i = Int(t / step) % notes.count, local = t.truncatingRemainder(dividingBy: step)
    let f = notes[i], env = exp(-local * 3.2)
    return env * (sin(2 * .pi * f * t) + 0.35 * sin(2 * .pi * f * 2.01 * t) + 0.15 * sin(2 * .pi * f * 3.0 * t)) / 1.5
}

func sunrise(_ t: Double) -> Double {
    let chord = [261.63, 329.63, 392.0, 493.88]
    let swell = 0.6 + 0.4 * sin(2 * .pi * t / 4)
    return swell * chord.enumerated().reduce(0) { $0 + sin(2 * .pi * $1.element * t + Double($1.offset)) } / 4
}

func pulse(_ t: Double) -> Double {
    let cycle = t.truncatingRemainder(dividingBy: 1.0)
    let on = cycle < 0.12 || (cycle > 0.2 && cycle < 0.32)
    let edge = on ? 1.0 : 0.0
    return edge * sin(2 * .pi * 880 * t) * 0.8
}

func write(_ name: String, _ voice: (Double) -> Double, to dir: URL) throws {
    let format = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1)!
    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames))!
    buffer.frameLength = AVAudioFrameCount(frames)
    let data = buffer.floatChannelData![0]
    for n in 0..<frames {
        let t = Double(n) / rate
        let fade = min(1, (seconds - t) / 0.05)
        data[n] = Float(0.85 * ramp(t) * voice(t) * fade)
    }
    let settings: [String: Any] = [
        AVFormatIDKey: kAudioFormatAppleIMA4, AVSampleRateKey: rate, AVNumberOfChannelsKey: 1,
    ]
    let url = dir.appendingPathComponent("\(name).caf")
    try? FileManager.default.removeItem(at: url)
    let file = try AVAudioFile(forWriting: url, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
    try file.write(from: buffer)
}

let dir = URL(fileURLWithPath: CommandLine.arguments[1])
try write("dawn-chimes", chimes, to: dir)
try write("dawn-sunrise", sunrise, to: dir)
try write("dawn-pulse", pulse, to: dir)
print("wrote 3 clips to \(dir.path)")
