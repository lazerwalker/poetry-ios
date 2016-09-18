import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    var networkInterface:NetworkInterface?
    let voice = RobotVoiceOutput()

    let locationSensor = LocationSensor()
    let weatherSensor = WeatherSensor()
    let timeSensor = TimeSensor()

    let calculator:InputCalculator

    var running = false

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var primetextLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

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
            self.locationLabel.text = self.locationSensor.currentRegion()?.title

            if let speed = self.locationSensor.currentSpeed() {
                self.speedLabel.text = String(speed)
            }
//            self.weatherSensor.location = location.coordinate
//            self.weatherSensor.getWeather({ (forecast) in })
        }

        locationSensor.start()

        // Map view setup
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
        locationSensor.regions.forEach { (fence) in
            self.mapView.addOverlay(fence.polygon)
            self.mapView.addAnnotation(fence.polygon)
        }
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
        self.primetextLabel.text = result.primetext
        self.primetextLabel.sizeToFit()

        self.voice.speak(result.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //-
    // MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKPointAnnotation.self) || annotation.isKindOfClass(MKPolygon.self) {
            let identifier = NSStringFromClass(MKPinAnnotationView.self)
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if (pinView == nil) {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            pinView?.pinTintColor = MKPinAnnotationView.greenPinColor()
            pinView?.canShowCallout = true
            return pinView
        }
        return nil
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolygon.self) {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            renderer.lineWidth = 0.5;

            return renderer
        }

        // This case should never be reached, and fail silently.
        // But this function doesn't have a return type of Optional.
        // Obj-C interop is hard!
        return MKCircleRenderer()
    }
}

