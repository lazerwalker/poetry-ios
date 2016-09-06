import Foundation
import SQLite

let table = Table("primetexts")
let location = Expression<String>("location")
let primetext = Expression<String>("primetext")

struct InputCalculator {
    let locationSensor:LocationSensor
    let weatherSensor:WeatherSensor
    let timeSensor:TimeSensor

    init(location:LocationSensor, weather:WeatherSensor, time:TimeSensor) {
        self.locationSensor = location
        self.weatherSensor = weather
        self.timeSensor = time
    }

    func nextInput() -> StanzaInput {
        if let foundPrimetext = primetextForRegion(self.locationSensor.currentRegion()?.title) {
            return StanzaInput(primetext:foundPrimetext, temperature:40, length: 20)
        } else {
            print("UH OH UH OH couldn't find a primetext")
            return StanzaInput(primetext: "uh oh", temperature: 50, length: 20)
        }
    }

    //-
    func primetextForRegion(region:String?) -> String? {
        let loc = (region != nil ? region! : "fallback")

        if let db = DB.connectionToPoetryDB() {
            let query = table
                .filter(location == loc)
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