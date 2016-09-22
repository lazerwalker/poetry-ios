import CoreLocation
import Foundation
import MapKit

class LocationSensor : NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var onLocationChange:[(CLLocation -> Void)] = []
    var running = false
    var fakedLocation:CLLocation?

    let regions:[Geofence]

    let fortMason = CLLocationCoordinate2D(latitude: 37.806, longitude: -122.429)

    override init() {
        let regionJSON = NSBundle.mainBundle().pathForResource("regions", ofType: "json")
        let content = try! String(contentsOfFile: regionJSON!, encoding: NSUTF8StringEncoding)
        regions = Geofence.fromJSONArray(content)

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

    func fakeLocation(coord:CLLocationCoordinate2D) {
        stop()
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        self.fakedLocation = location
        onLocationChange.forEach { (cb) in
            cb(location)
        }
    }

    func addLocationHandler(handler:(CLLocation) -> Void) {
        onLocationChange.append(handler)
    }

    func isInsideFortMason() -> Bool {
        if let location = currentLocation() {
            let masonLoc = CLLocation(latitude: fortMason.latitude, longitude: fortMason.longitude)
            return location.distanceFromLocation(masonLoc) < 800.0
        } else {
            return false
        }
    }

    func currentLocation() -> CLLocation? {
        if self.running {
            return manager.location
        } else {
            return self.fakedLocation
        }
    }

    func currentRegion() -> MKPolygon? {
        if let location = currentLocation() {
//            let mapPoint = MKMapPointForCoordinate(location.coordinate)
            let point = CGPointMake(CGFloat(location.coordinate.latitude), CGFloat(location.coordinate.longitude))

            let containingRegions = regions.filter { (region) -> Bool in
                return CGPathContainsPoint(region.path, nil, point, false)
            }

            if containingRegions.count == 0 {
                return nil
            } else if containingRegions.count == 1 {
                return containingRegions.first!.polygon
            } else {
                return containingRegions.sort({ (first, second) -> Bool in
                    let firstLocation = CLLocation(latitude: first.polygon.coordinate.latitude, longitude: first.polygon.coordinate.longitude)
                    let secondLocation = CLLocation(latitude: second.polygon.coordinate.latitude, longitude: second.polygon.coordinate.longitude)
                    return location.distanceFromLocation(firstLocation) < location.distanceFromLocation(secondLocation)
                }).first!.polygon
            }
        }

        return nil
    }

    func currentSpeed() -> Double {
        let speed = manager.location?.speed
        if (speed == nil) { return 0.0 }
        if (speed == -1.0) { return 0.0 }
        return abs(speed!)
    }

    // - Private

    func startLocationUpdates() {
        manager.startUpdatingLocation()
        if let location = manager.location {
            onLocationChange.forEach({ (cb) in
                cb(location)
            })
        }
    }

    // - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            onLocationChange.forEach { (cb) in
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
