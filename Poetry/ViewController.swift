import UIKit

class ViewController: UIViewController {
    var networkInterface:NetworkInterface?
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()
    let timeSensor = TimeSensor()

    var running = false

    override func viewDidLoad() {
        super.viewDidLoad()
        running = true

        if let config = Config() {
            networkInterface = NetworkInterface(hostname: config.serverRoot)
        }

        fetchPoetry()

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

    func fetchPoetry() {
        networkInterface?.fetchPoetryWithText("I wonder if", temperature: 0.4, callback: poetryHandler)
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

