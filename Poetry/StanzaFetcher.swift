import Foundation
import SQLite

struct StanzaFetcher {
    static let table = Table("stanzas")
    static let text = Expression<String>("text")
    static let primetext = Expression<String>("primetext")
    static let temperature = Expression<Int>("temperature")
    static let length = Expression<Int>("length")

    static func connectionToPoetryDB() -> Connection? {
        let path = NSBundle.mainBundle().pathForResource("poetry", ofType: "db")!

        do {
            return try Connection(path, readonly: true)
        } catch {
            return nil
        }
    }

    // TODO: length is not used
    static func fetchWithPrimetext(primetext:String, temperature:Int, length:Int) {
        if let db = StanzaFetcher.connectionToPoetryDB() {
            let query = table.filter(self.primetext == primetext && self.temperature == temperature)
            let items = try! db.prepare(query)
            for item in items {
                print(item)
            }
        }

    }
}