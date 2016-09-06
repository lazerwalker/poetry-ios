import Foundation
import SQLite

struct StanzaFetcher {
    static let table = Table("stanzas")
    static let text = Expression<String>("text")
    static let primetext = Expression<String>("primetext")
    static let temperature = Expression<Int>("temperature")
    static let length = Expression<Int>("length")

    // TODO: length is not used
    static func fetch(input:StanzaInput) -> Stanza? {
        if let db = DB.connectionToPoetryDB() {
            let query = table
                .filter(self.primetext == input.primetext)
                .filter(self.temperature == input.temperature)
                .order(Expression<Int>.random())
                .limit(1)

            let items = try! db.prepare(query)
            return items.map({ (item) in
                return Stanza(text: item[text], primetext: input.primetext, temperature: input.temperature)
            }).first
        }
        return nil
    }
}