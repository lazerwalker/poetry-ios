import UIKit

class ViewController: UIViewController {
    var networkInterface:NetworkInterface?
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()
    let timeSensor = TimeSensor()

    var running = false

    override func viewDidLoad() {
        voice.onComplete = prepareNextStanza

        super.viewDidLoad()
        running = true

        if let stanza = StanzaFetcher.fetchWithPrimetext("The sun shone", temperature: 40, length: 20) {
            speak(stanza)
        }

        print(timeSensor.isWeekday())
        print(timeSensor.timeOfDay())

        locationSensor.onLocationChange = { location in
            print(location)
            self.weatherSensor.location = location.coordinate
            self.weatherSensor.getWeather({ (forecast) in
                print(forecast)
            })
        }

        locationSensor.start()
    }

    func prepareNextStanza() {
        if self.running {
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                if let stanza = StanzaFetcher.fetchWithPrimetext("The sun shone", temperature: 40, length: 20) {
                    self.speak(stanza)
                }
            })
        }
    }

    func speak(result:Stanza) {
        print(result)

        self.voice.speak(result.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

