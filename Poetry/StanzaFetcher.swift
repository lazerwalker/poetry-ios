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
    static func fetchWithPrimetext(primetext:String, temperature:Int, length:Int) -> Stanza? {
        if let db = StanzaFetcher.connectionToPoetryDB() {
            let query = table
                .filter(self.primetext == primetext)
                .filter(self.temperature == temperature)
                .order(Expression<Int>.random())
                .limit(1)

            let items = try! db.prepare(query)
            return items.map({ (item) in
                return Stanza(text: item[text], primetext: primetext, temperature: temperature)
            }).first
        }
        return nil
    }
}