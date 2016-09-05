import Foundation
import MapKit

struct Geofence {
    static func fromJSON(json:String) -> MKCircle? {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
            if let centerString = json["center"] as? String,
                title = json["title"] as? String,
                radius = json["radius"] as? CLLocationDistance {

                let centerLatLng = centerString.componentsSeparatedByString(",")
                let lat = (centerLatLng[0] as NSString).doubleValue
                let long = (centerLatLng[1] as NSString).doubleValue
                let center = CLLocationCoordinate2DMake(lat, long)

                let circle = MKCircle(centerCoordinate: center, radius: radius)
                circle.title = title
                return circle
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }

    static func circlesFromJSON(json:String) -> [MKCircle] {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [[String: AnyObject]]
            return json.map({ (object) in
                if let centerString = object["center"] as? String,
                    title = object["title"] as? String,
                    radius = object["radius"] as? CLLocationDistance {

                    let centerLatLng = centerString.componentsSeparatedByString(",")
                    let lat = (centerLatLng[0] as NSString).doubleValue
                    let long = (centerLatLng[1] as NSString).doubleValue
                    let center = CLLocationCoordinate2DMake(lat, long)

                    let circle = MKCircle(centerCoordinate: center, radius: radius)
                    circle.title = title
                    return circle
                }
                return MKCircle() // Shouldn't reach this
            })
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return []
        }
    }
}
