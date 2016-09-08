import CoreLocation
import Foundation
import MapKit

class LocationSensor : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var onLocationChange:(CLLocation -> Void)?
    var running = false

    let regions:[MKCircle]

    override init() {
        let regionJSON = NSBundle.mainBundle().pathForResource("regions", ofType: "json")
        let content = try! String(contentsOfFile: regionJSON!, encoding: NSUTF8StringEncoding)
        regions = Geofence.circlesFromJSON(content)

        super.init()
        manager.delegate = self
    }

    func start() {
        running = true
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            manager.requestAlwaysAuthorization()
        } else if status == .AuthorizedAlways {
            startLocationUpdates()
        }
    }

    func stop() {
        running = false
        manager.stopUpdatingLocation()
    }

    func currentRegion() -> MKCircle? {
        if let location = manager.location {
            let mapPoint = MKMapPointForCoordinate(location.coordinate)

            let containingRegions = regions.filter { (circle) -> Bool in
                return MKMapRectContainsPoint(circle.boundingMapRect, mapPoint)
            }

            if containingRegions.count == 0 {
                return nil
            } else if containingRegions.count == 1 {
                return containingRegions.first!
            } else {
                return containingRegions.sort({ (circle1, circle2) -> Bool in
                    return circle1.radius < circle2.radius
                }).first!
            }
        }

        return nil
    }

    func currentSpeed() -> CLLocationSpeed? {
        return manager.location?.speed
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
