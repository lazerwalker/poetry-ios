import Alamofire
import Foundation

class NetworkInterface {
    let hostname:String

    var poetryRoute:String {
        get {
            return "\(hostname)/poetry"
        }
    }

    init(hostname:String) {
        self.hostname = hostname
    }

    func fetchPoetryWithText(text:String, temperature:Float, callback:(String -> Void) ) {
        let options:[String:AnyObject] = [
            "primetext": text,
            "temperature": temperature
        ]
        Alamofire.request(.GET, poetryRoute, parameters:options)
            .responseJSON { response in
                if let data = response.data,
                    poetry = String(data: data, encoding: NSUTF8StringEncoding) {
                    callback(poetry)
                } else {
                    print("ERROR", response.result)
                }
        }
    }
}