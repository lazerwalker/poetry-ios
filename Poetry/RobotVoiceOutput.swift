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
        synthesizer.speakUtterance(utterance)
    }

    //- AVSpeechSynthesizerDelegate

}
