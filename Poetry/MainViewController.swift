import Foundation
import UIKit
import MapKit

class MainViewController : UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var debugButton: UIButton!

    var generator:PoetryGenerator?
    var showedWarning = false

    override func viewDidLoad() {
        self.mapView.showsScale = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false

        self.mapView.showsUserLocation = true

        mapView.userInteractionEnabled = false

        let fortMason = CLLocationCoordinate2D(latitude: 37.809, longitude: -122.429)

        let region = MKCoordinateRegion(center: fortMason, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(region, animated: false)

        generator?.calculator.locationSensor.onLocationChange = { (location) in
            if self.generator!.calculator.locationSensor.isInsideFortMason() {
                self.showedWarning = false
                if (!self.generator!.running) {
                    self.generator?.start()
                }
            } else {
                if (!self.showedWarning) {
                    let alert = UIAlertController(title: "You're not in Fort Mason!", message: "Computational Flâneur is a site-specific experience. To take part, you need to be at Fort Mason in San Francisco, CA.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alert.addAction(ok)

                    self.presentViewController(alert, animated: true, completion: nil)
                    self.showedWarning = true
                }
            }
        }
    }

    @IBAction func didTapDebugButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "DebugViewController", bundle: NSBundle.mainBundle())
        if let debugVC = storyboard.instantiateInitialViewController() as? DebugViewController {
            debugVC.generator = self.generator
            self.presentViewController(debugVC, animated: true, completion: nil)
        }

    }

}
