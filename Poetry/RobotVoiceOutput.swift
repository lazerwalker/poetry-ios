import AVFoundation
import Foundation

class RobotVoiceOutput:NSObject, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.pauseSpeakingAtBoundary(.Word)
    }

    func speak(text:String) {
        let utterance = AVSpeechUtterance(string:text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IE")

        let pitchModulator = (Float(arc4random_uniform(30))/100.0 - 0.15)
        utterance.pitchMultiplier = 1.0 + pitchModulator

        print("Playing at pitch \(utterance.pitchMultiplier)")
        synthesizer.speakUtterance(utterance)
    }

    //- AVSpeechSynthesizerDelegate

}
