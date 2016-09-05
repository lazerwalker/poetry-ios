import Foundation

struct StanzaInput {
    let primetext:String
    let temperature:Int
    let length:Int

    init(primetext:String, temperature:Int, length:Int) {
        self.primetext = primetext
        self.temperature = temperature
        self.length = length
    }
}
