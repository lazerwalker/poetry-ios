import CoreLocation
import Keys
import ForecastIO
import Foundation

class WeatherSensor {
    let client:APIClient
    var location:CLLocationCoordinate2D?

    var cachedWeather:DataPoint?

    init() {
        let keys = PoetryKeys()
        client = APIClient(apiKey: keys.forecastIOAPIKey())
    }

    func getWeather(cb:(DataPoint -> Void)) {
        if let coords = location {
            if let weather = cachedWeather {
                cb(weather)
            } else {
                client.getForecast(latitude: coords.latitude, longitude: coords.longitude) { (currentForecast, error) in
                    if let currentForecast = currentForecast, currently = currentForecast.currently {
                        self.cachedWeather = currently
                        cb(currently)
                    } else if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
}