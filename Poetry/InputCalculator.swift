import Foundation
import SQLite

let table = Table("primetexts")
let location = Expression<String>("location")
let primetext = Expression<String>("primetext")

struct InputCalculator {
    let locationSensor:LocationSensor
    let weatherSensor:WeatherSensor
    let timeSensor:TimeSensor

    var failureCount = 0

    var previousPrimetext:String

    init(location:LocationSensor, weather:WeatherSensor, time:TimeSensor) {
        self.locationSensor = location
        self.weatherSensor = weather
        self.timeSensor = time

        previousPrimetext = ""
    }

    func nextInput(fallback:Bool = false) -> StanzaInput {
        let region = (fallback ? nil : self.locationSensor.currentRegion()?.title)
        if let foundPrimetext = primetextForRegion(region) {
            let temperature = speedToTemperature(self.locationSensor.currentSpeed())
            return StanzaInput(primetext:foundPrimetext, temperature:temperature, length: 20)
        } else {
            print("UH OH UH OH couldn't find a primetext")
            return nextInput(true)
        }
    }

    //-
    func speedToTemperature(speed:Double) -> Int {
        var choices:[Int] = []
        if (speed <= 1.0) {
            choices = [30, 40]
        } else if (speed <= 1.6) {
            choices = [40, 50]
        } else if (speed <= 2.0) {
            choices = [50, 60]
        } else if (speed > 2.0) {
            choices = [60, 70]
        }
        let idx = Int(arc4random_uniform(UInt32(choices.count)))
        return choices[idx]
    }

    func primetextForRegion(region:String?) -> String? {
        let loc = (region != nil ? region! : "fallback")

        if let db = DB.connectionToPoetryDB() {
            let query = table
                .filter(location == loc)
                .filter(primetext != self.previousPrimetext)
                .order(Expression<Int>.random())
                .limit(1)

            let items = try! db.prepare(query)
            return items.map({ (item) in
                return item[primetext]
            }).first
        }
        return nil
    }
}
