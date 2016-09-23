import Foundation
import MapKit

enum PlayStatus {
    case Playing
    case Paused
    case Stopped
}

protocol Playable {
    func currentStatus() -> PlayStatus

    func play() -> PlayStatus
    func stop() -> PlayStatus
    func pause() -> PlayStatus
    func playPause() -> PlayStatus
}

// TODO: This class, and InputCalculator, are clearly factored wrong.
// Figure out the proper abstraction.

class PoetryGenerator : Playable {
    let calculator:InputCalculator
    let voice = RobotVoiceOutput()
    let bgAudio = BackgroundAudioOutput()

    var previousRegion:MKPolygon?

    var running:Bool = false {
        didSet {
            statusDidUpdate()
        }
    }
    var paused:Bool = false {
        didSet {
            statusDidUpdate()
        }
    }

    var onSpeak:(Stanza -> Void)?
    var onChangePlayStatus:((PlayStatus) -> Void)?

    init(calculator:InputCalculator) {
        self.calculator = calculator
        self.voice.delegate = self
        voice.onComplete = prepareNextStanza

        calculator.locationSensor.addLocationHandler { (location) in
            if let region = self.calculator.locationSensor.currentRegion(),
                title = region.title {
                if title != self.previousRegion?.title {
                    print("New region!", title)
                    self.bgAudio.fadeInSoundscape(title)

                    if let previousTitle = self.previousRegion?.title {
                        self.bgAudio.fadeOutSoundscape(previousTitle)
                    }
                }
                self.previousRegion = region
            }
        }
    }

    //-
    // Playable

    func currentStatus() -> PlayStatus {
        if running && paused {
            return .Paused
        } else if running && !paused {
            return .Playing
        } else {
            return .Stopped
        }
    }
    func play() -> PlayStatus {
        running = true
        paused = false

        if let stanza = StanzaFetcher.fetch(calculator.nextInput()) {
            speak(stanza)
        }

        return currentStatus()
    }

    func stop() -> PlayStatus {
        paused = false
        running = false
        calculator.locationSensor.stop()

        return currentStatus()
    }

    func pause() -> PlayStatus {
        paused = true
        return currentStatus()
    }

    func playPause() -> PlayStatus {
        switch(currentStatus()) {
        case .Playing:
            pause()
        case .Paused:
            play()
        case .Stopped:
            play()
        }
        return currentStatus()
    }

    func statusDidUpdate() {
        let status = currentStatus()
        voice.updatePlayStatus(status)
        if let cb = onChangePlayStatus {
            cb(status)
        }
    }

    //-
    func fakeLocation() {
        calculator.locationSensor.fakeLocation(calculator.locationSensor.fortMason)
    }

    //-
    func prepareNextStanza() {
        if currentStatus() == .Playing {
            var speed = self.calculator.locationSensor.currentSpeed()
            if speed == 0 { speed = 0.6 }

            let seconds = 1.6 / speed
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                if let stanza = StanzaFetcher.fetch(self.calculator.nextInput()) {
                    self.speak(stanza)
                }
            })
        }
    }

    func speak(result:Stanza) {
        print(result)
        if let cb = onSpeak {
            cb(result)
        }

        self.voice.speak(result.text, speed:self.calculator.locationSensor.currentSpeed())
    }
}
