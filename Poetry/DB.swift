import Foundation
import SQLite

struct DB {
    static func connectionToPoetryDB() -> Connection? {
        let path = NSBundle.mainBundle().pathForResource("poetry", ofType: "db")!

        do {
            return try Connection(path, readonly: true)
        } catch {
            return nil
        }
    }
}