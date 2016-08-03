import CoreLocation
import Foundation

class LocationSensor : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    var onLocationChange:(CLLocation -> Void)?
    var running = false

    override init() {
        super.init()
        manager.delegate = self
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
