import Foundation
import SQLite

let table = Table("primetexts")
let location = Expression<String>("location")
let primetext = Expression<String>("primetext")

struct InputCalculator {
    let locationSensor:LocationSensor
    let timeSensor:TimeSensor

    var failureCount = 0

    var previousPrimetext:String

    init(location:LocationSensor, time:TimeSensor) {
        self.locationSensor = location
        self.timeSensor = time

        previousPrimetext = ""

        self.locationSensor.start()
    }

    func nextInput(fallback:Bool = false) -> StanzaInput {
        // This separate declaration shouldn't be necessary
        // but is stopping a weird crash when faking location?
        let region = self.locationSensor.currentRegion()

        let regionText = (fallback ? nil : region?.title)
        if let foundPrimetext = primetextForRegion(regionText) {
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
