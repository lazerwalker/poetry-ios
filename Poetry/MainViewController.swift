import Foundation
import UIKit
import MapKit
import SafariServices
import IntentKit

class MainViewController : UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    
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

        generator?.onChangePlayStatus = updatePlayButton

        generator?.calculator.locationSensor.addLocationHandler() { (location) in
            if self.generator!.calculator.locationSensor.isInsideFortMason() {
                self.showedWarning = false
                self.playPauseButton.hidden = false
                self.directionsButton.hidden = true
            } else {
                self.playPauseButton.hidden = true
                self.directionsButton.hidden = false
                if (!self.showedWarning) {
                    let alert = UIAlertController(title: "You're not in Fort Mason!", message: "Computational Flâneur is a site-specific experience. To take part, you need to be at Fort Mason in San Francisco, CA.", preferredStyle: .Alert)

                    let ok = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alert.addAction(ok)
                    
                    let directions = UIAlertAction(title: "Get Directions", style: .Default) {
                        (_) in self.showMaps()
                    }
                    alert.addAction(directions)

                    self.presentViewController(alert, animated: true, completion: nil)
                    self.showedWarning = true
                }
            }
        }

        #if DEBUG
            generator?.fakeLocation()
            debugButton.hidden = false
        #endif
    }

    func updatePlayButton(status:PlayStatus) {
        if (status == .Paused || status == .Stopped ) {
            self.playPauseButton.setImage(UIImage(named:"Play"), forState: .Normal)
            self.playPauseButton.setTitle("Play", forState: .Normal)
        } else if status == .Playing {
            self.playPauseButton.setImage(UIImage(named:"Pause"), forState: .Normal)
            self.playPauseButton.setTitle("Pause", forState: .Normal)
        }
    }

    func showMaps() {
        let handler = INKMapsHandler()
        if let location = self.generator?.calculator.locationSensor.currentLocation() {
            let coordString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            handler.directionsFrom(coordString, to: "Fort Mason").presentModally()
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

    @IBAction func didTapDirectionsButton(sender: AnyObject) {
        showMaps()
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

    @IBAction func didTapAcknowledgements(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "AcknowledgementsViewController", bundle: NSBundle.mainBundle())
        if let nav = storyboard.instantiateInitialViewController() as? UINavigationController {
            if let vc = nav.topViewController as? AcknowledgementsViewController {
                vc.completionBlock = {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            self.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    //-
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
