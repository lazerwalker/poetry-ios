import Foundation

struct Config {
    let serverRoot:String

    init?() {
        // TODO: This is a flaming pile of garbage.
        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
            let myDict = NSDictionary(contentsOfFile: path)
            if let dict = myDict, serverRoot = dict["serverRoot"] as? String {
                self.serverRoot = serverRoot
                return
            }
        }
        return nil
    }
}
