import Foundation

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
        return StanzaInput(primetext:"The sun shone", temperature:40, length: 20)
    }
}