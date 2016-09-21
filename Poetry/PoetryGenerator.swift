import Foundation

class PoetryGenerator {
    let calculator:InputCalculator
    let voice = RobotVoiceOutput()

    var running:Bool = false

    var onSpeak:(Stanza -> Void)?

    init(calculator:InputCalculator) {
        self.calculator = calculator
        voice.onComplete = prepareNextStanza
    }

    func start() {
        running = true
        calculator.locationSensor.start()

        if let stanza = StanzaFetcher.fetch(calculator.nextInput()) {
            speak(stanza)
        }
    }

    func stop() {
        running = false
        calculator.locationSensor.stop()
    }

    //-
    func prepareNextStanza() {
        if self.running {
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
