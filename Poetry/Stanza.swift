import Foundation

struct Stanza {
    let text:String
    let primetext:String
    let temperature:Int

    init(text:String, primetext:String, temperature:Int) {
        self.text = text
        self.primetext = primetext
        self.temperature = temperature
    }
}