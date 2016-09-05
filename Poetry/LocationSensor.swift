import CoreLocation
import Foundation
import MapKit

class LocationSensor : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var onLocationChange:(CLLocation -> Void)?
    var running = false

    override init() {
        super.init()
        manager.delegate = self

        let regions = NSBundle.mainBundle().pathForResource("regions", ofType: "json")
        let content = try! String(contentsOfFile: regions!, encoding: NSUTF8StringEncoding)
        if let circles = Geofence.circlesFromJSON(content) {
            print(circles)
        }
    }

    func start() {
        running = true
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .AuthorizedAlways {
            startLocationUpdates()
        }
    }

    func stop() {
        running = false
        manager.stopUpdatingLocation()
    }

//    func currentRegion

    // - Private

    func startLocationUpdates() {
        manager.startUpdatingLocation()
        if let cb = onLocationChange, location = manager.location {
            cb(location)
        }
    }

    // - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let cb = onLocationChange {
            if let last = locations.last {
                cb(last)
            }
        }
    }

    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if running && status == .AuthorizedAlways {
            startLocationUpdates()
        }
    }
}
