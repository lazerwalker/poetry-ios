import Foundation
import MapKit

struct Geofence {
    let polygon:MKPolygon
    let path:CGPath

    init(polygon:MKPolygon, path:CGPath) {
        self.polygon = polygon
        self.path = path
    }

    static func fromJSONObject(json:[String: AnyObject]) -> Geofence? {
        if let pointStrings = json["points"] as? [String],
        let title = json["title"] as? String {
            let points = pointStrings.map({ (str) -> CLLocationCoordinate2D in
                let latlng = str.componentsSeparatedByString(",")
                let lat = (latlng[0] as NSString).doubleValue
                let lng = (latlng[1] as NSString).doubleValue
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            })
            let pointer:UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(points)
            let polygon = MKPolygon(coordinates: pointer, count: points.count)
            polygon.title = title

            let path:CGMutablePathRef = CGPathCreateMutable()
            let array = Array(UnsafeBufferPointer(start:points, count: polygon.pointCount))
            var started = false
            array.forEach({ (point) in
                if (started) {
                    CGPathAddLineToPoint(path, nil, CGFloat(point.latitude), CGFloat(point.longitude))
                } else {
                    CGPathMoveToPoint(path, nil, CGFloat(point.latitude), CGFloat(point.longitude))
                    started = true
                }
            })
            CGPathCloseSubpath(path)

            return Geofence(polygon: polygon, path:path)
        }
        return nil
    }

    static func fromJSON(json:String) -> Geofence? {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
            return self.fromJSONObject(json)
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }

    static func fromJSONArray(json:String) -> [Geofence] {
        do {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [[String: AnyObject]]
            return json
                .map({ return self.fromJSONObject($0)! })
                .filter({ return !($0 == nil) })

        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return []
        }
    }
}
