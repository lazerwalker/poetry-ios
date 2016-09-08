import Foundation
import CoreMotion

class MotionSensor {
    let manager = CMMotionManager()

    var onAccelerationChange:(String -> Void)?

    init() {
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdatesUsingReferenceFrame(.XTrueNorthZVertical, toQueue: NSOperationQueue.mainQueue()) { (data: CMDeviceMotion?, error: NSError?) in

                if let data = data, cb = self.onAccelerationChange {
                    let str = "\(data.userAcceleration.x)\n\(data.userAcceleration.y)\n\(data.userAcceleration.z)"
                    cb(str)
                }
            }
        }
    }
}