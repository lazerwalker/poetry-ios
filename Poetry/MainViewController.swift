import Foundation
import UIKit
import MapKit

class MainViewController : UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var debugButton: UIButton!

    var generator:PoetryGenerator?

    override func viewDidLoad() {
        self.mapView.showsScale = false
        self.mapView.showsTraffic = false
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false

        self.mapView.showsUserLocation = true

        let fortMason = CLLocationCoordinate2D(latitude: 37.806, longitude: -122.429)
        mapView.userInteractionEnabled = false
        let region = MKCoordinateRegion(center: fortMason, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(region, animated: false)
    }

    @IBAction func didTapDebugButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "DebugViewController", bundle: NSBundle.mainBundle())
        if let debugVC = storyboard.instantiateInitialViewController() as? DebugViewController {
            debugVC.generator = self.generator
            self.presentViewController(debugVC, animated: true, completion: nil)
        }

    }

}
