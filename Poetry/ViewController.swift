import UIKit

class ViewController: UIViewController {
    let networkInterface = NetworkInterface(hostname: "http://localhost:3000")
    let voice = RobotVoiceOutput()
    let locationSensor = LocationSensor()

    var running = false

    override func viewDidLoad() {
        super.viewDidLoad()
        running = true
        fetchPoetry()

        locationSensor.onLocationChange = { location in
            print(location)
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

