import AVFoundation
import Foundation

class RobotVoiceOutput:NSObject, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()

    var onComplete:(()->Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.pauseSpeakingAtBoundary(.Word)
    }

    func speak(text:String) {
        let utterance = AVSpeechUtterance(string:text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IE")

        func randomNumberNear(start:Float, within:Float) -> Float {
            let modifier = (Float(arc4random_uniform(UInt32(within * 100 * 2)))/100.0 - within)
            return start + modifier
        }

        utterance.pitchMultiplier = randomNumberNear(1.0, within: 0.15)

        let rateSpread = (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate) / 8
        utterance.rate = randomNumberNear(AVSpeechUtteranceDefaultSpeechRate, within: rateSpread)

        print("Playing at pitch \(utterance.pitchMultiplier), rate \(utterance.rate)")
        synthesizer.speakUtterance(utterance)
    }

    //- AVSpeechSynthesizerDelegate
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        if let cb = self.onComplete {
            cb()
        }
    }
}
