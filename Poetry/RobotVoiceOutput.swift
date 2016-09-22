import AVFoundation
import Foundation
import MediaPlayer

class RobotVoiceOutput:NSObject, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()

    var onComplete:(()->Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.pauseSpeakingAtBoundary(.Word)

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }

        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTargetWithHandler(continuePlaying)
        commandCenter.stopCommand.addTargetWithHandler(stopPlaying)
        commandCenter.pauseCommand.addTargetWithHandler(pausePlaying)
        commandCenter.togglePlayPauseCommand.addTargetWithHandler(playPause)
        
        let nowPlaying = MPNowPlayingInfoCenter.defaultCenter()
        nowPlaying.nowPlayingInfo = [
            MPMediaItemPropertyTitle: "Computational Flaneur",
            MPMediaItemPropertyArtist: "Mike Lazer-Walker",
        ]
    }

    //-
    func continuePlaying(event:MPRemoteCommandEvent?) -> MPRemoteCommandHandlerStatus {
        if (self.synthesizer.continueSpeaking()) {
            return .Success
        } else {
            return .CommandFailed
        }
    }

    func pausePlaying(event:MPRemoteCommandEvent?) -> MPRemoteCommandHandlerStatus {
        if (self.synthesizer.pauseSpeakingAtBoundary(.Word)) {
            return .Success
        } else {
            return .CommandFailed
        }
    }

    func stopPlaying(event:MPRemoteCommandEvent?) -> MPRemoteCommandHandlerStatus {
        if (self.synthesizer.stopSpeakingAtBoundary(.Word)) {
            return .Success
        } else {
            return .CommandFailed
        }
    }

    func playPause(event:MPRemoteCommandEvent?) -> MPRemoteCommandHandlerStatus {
        if (self.synthesizer.speaking && !self.synthesizer.paused) {
            return pausePlaying(event)
        } else if (self.synthesizer.paused) {
            return continuePlaying(event)
        }
        return .NoActionableNowPlayingItem
    }

    //-

    func speak(text:String, speed:Double) {
        let utterance = AVSpeechUtterance(string:text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IE")

        func randomNumberNear(start:Float, within:Float) -> Float {
            let modifier = (Float(arc4random_uniform(UInt32(within * 100 * 2)))/100.0 - within)
            return start + modifier
        }

        utterance.pitchMultiplier = randomNumberNear(1.0, within: 0.15)

        let rateSpread = (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate) / 10

        if speed >= 2.0 {
            utterance.rate = randomNumberNear(AVSpeechUtteranceDefaultSpeechRate + rateSpread/2, within: rateSpread/2)
        } else if speed <= 1.0 {
            utterance.rate = randomNumberNear(AVSpeechUtteranceDefaultSpeechRate - rateSpread/2, within: rateSpread/2)
        } else {
            utterance.rate = randomNumberNear(AVSpeechUtteranceDefaultSpeechRate, within: rateSpread)
        }
        
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
