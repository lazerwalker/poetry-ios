import UIKit

class ViewController: UIViewController {
    var networkInterface:NetworkInterface?
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()
    let timeSensor = TimeSensor()

    var running = false

    override func viewDidLoad() {
        voice.onComplete = {
            if self.running {
                if let stanza = StanzaFetcher.fetchWithPrimetext("The sun shone", temperature: 40, length: 20) {
                    self.speak(stanza)
                }
            }
        }

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


    func speak(result:Stanza) {
        print(result)

        self.voice.speak(result.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

