import UIKit
import MapKit

class DebugViewController: UIViewController, MKMapViewDelegate {
    var networkInterface:NetworkInterface?

    var generator:PoetryGenerator?

    var running = false

    var userPin:MKPointAnnotation?

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var primetextLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        generator?.calculator.locationSensor.onLocationChange = { location in
            self.locationLabel.text = self.generator?.calculator.locationSensor.currentRegion()?.title
            self.speedLabel.text = String(self.generator?.calculator.locationSensor.currentSpeed())
//            self.weatherSensor.location = location.coordinate
//            self.weatherSensor.getWeather({ (forecast) in })
        }

        generator?.onSpeak = {
            self.primetextLabel.text = $0.primetext
            self.primetextLabel.sizeToFit()
        }

        // Map view setup
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
        generator?.calculator.locationSensor.regions.forEach { (fence) in
            self.mapView.addOverlay(fence.polygon)
            self.mapView.addAnnotation(fence.polygon)
        }

        // Debug location setting
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(DebugViewController.changeLocation(_:)))
        mapView.addGestureRecognizer(recognizer)

        generator?.start()
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

            if (annotation.isKindOfClass(MKPointAnnotation.self)) {
                pinView?.pinTintColor = UIColor.blueColor()
                pinView?.canShowCallout = false
            } else {
                pinView?.pinTintColor = MKPinAnnotationView.greenPinColor()
                pinView?.canShowCallout = true
            }
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

    //-
    func changeLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        let point = gestureRecognizer.locationInView(self.mapView)
        let coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
        self.generator?.calculator.locationSensor.fakeLocation(coordinate)
        self.mapView.showsUserLocation = false

        if let pin = self.userPin {
            self.mapView.removeAnnotation(pin)
        }

        let userPin = MKPointAnnotation()
        userPin.coordinate = coordinate
        userPin.title = "User Location"
        self.userPin = userPin
        self.mapView.addAnnotation(userPin)
    }
}

