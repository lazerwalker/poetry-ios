import UIKit

class ViewController: UIViewController {
    var networkInterface:NetworkInterface?
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()
    let timeSensor = TimeSensor()

    let calculator:InputCalculator

    var running = false

    @IBOutlet weak var coreLocationSpeed: UILabel!

    
    required init?(coder aDecoder: NSCoder) {
        calculator = InputCalculator(location: locationSensor, weather: weatherSensor, time: timeSensor)

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        voice.onComplete = prepareNextStanza

        super.viewDidLoad()
        running = true

        if let stanza = StanzaFetcher.fetch(calculator.nextInput()) {
            speak(stanza)
        }

        print(timeSensor.isWeekday())
        print(timeSensor.timeOfDay())


        locationSensor.onLocationChange = { location in
            self.weatherSensor.location = location.coordinate
            self.weatherSensor.getWeather({ (forecast) in })
        }

        locationSensor.start()
    }

    func prepareNextStanza() {
        if self.running {
            let seconds = 1.0
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

        self.voice.speak(result.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

