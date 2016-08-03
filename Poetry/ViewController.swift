import UIKit

class ViewController: UIViewController {
    let networkInterface = NetworkInterface(hostname: "http://48afd263.ngrok.io")
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()

    var running = false

    override func viewDidLoad() {
        super.viewDidLoad()
        running = true
        fetchPoetry()

        var fetchedWeather = false
        locationSensor.onLocationChange = { location in
            print(location)
            self.weatherSensor.location = location.coordinate
            if (!fetchedWeather) {
                self.weatherSensor.getWeather({ (forecast) in
                    print(forecast)
                    fetchedWeather = true
                })
            }
        }

        locationSensor.start()
    }

    func fetchPoetry() {
        networkInterface.fetchPoetryWithText("I wonder if", temperature: 0.4, callback: poetryHandler)
    }

    func poetryHandler(result:String) {
        print(result)
        self.voice.speak(result)

        if running {
            fetchPoetry()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

