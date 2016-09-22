import Foundation
import UIKit
import MapKit
import SafariServices

class MainViewController : UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!

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

        generator?.onChangePlayStatus = { (status) in
            if (status == .Paused || status == .Stopped ) {
                self.playPauseButton.setImage(UIImage(named:"Play"), forState: .Normal)
                self.playPauseButton.setTitle("Play", forState: .Normal)
            } else if status == .Playing {
                self.playPauseButton.setImage(UIImage(named:"Pause"), forState: .Normal)
                self.playPauseButton.setTitle("Pause", forState: .Normal)
            }
        }

        generator?.calculator.locationSensor.onLocationChange = { (location) in
            if self.generator!.calculator.locationSensor.isInsideFortMason() {
                self.showedWarning = false
                self.playPauseButton.hidden = false
            } else {
                self.playPauseButton.hidden = true
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
            debugVC.completionBlock = {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(debugVC, animated: true, completion: nil)
        }

    }

    @IBAction func didTapMikeButton(sender: AnyObject) {
        if let url = NSURL(string: "http://lazerwalker.com") {
            let webView = SFSafariViewController(URL: url)
            webView.delegate = self
            self.presentViewController(webView, animated: true, completion: nil)
        }
    }

    @IBAction func didTapCOAPButton(sender: AnyObject) {
        if let url = NSURL(string: "http://comeoutandplaysf.org") {
            let webView = SFSafariViewController(URL: url)
            webView.delegate = self
            self.presentViewController(webView, animated: true, completion: nil)
        }
    }

    @IBAction func didTapPlayPauseButton(sender: AnyObject) {
        generator?.playPause()
    }
    
    //-
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
