import Foundation
import SQLite3
import Combine

/// Správce dat, který načítá a ukládá historii tickerů do SQLite databáze pomocí sqlite3.
final class DataManager: ObservableObject {
    @Published var records: [TickerRecord] = []
    
    /// Ukazatel na otevřenou SQLite databázi.
    private var db: OpaquePointer? = nil
    
    init() {
        openDatabase()
        createTable()
        loadRecords()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - Inicializace databáze
    
    private func openDatabase() {
        guard let docsDir = try? FileManager.default.url(for: .documentDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: true) else {
            print("Chyba: Nelze získat Documents adresář.")
            return
        }
        let dbPath = docsDir.appendingPathComponent("tickers.sqlite").path
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Databáze úspěšně otevřena: \(dbPath)")
        } else {
            print("Chyba při otevírání databáze na: \(dbPath)")
            db = nil
        }
    }
    
    private func createTable() {
        let createSQL = """
        CREATE TABLE IF NOT EXISTS history(
            symbol TEXT PRIMARY KEY,
            name TEXT,
            date INTEGER
        );
        """
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabulka 'history' vytvořena nebo již existuje.")
            } else {
                let errMsg = String(cString: sqlite3_errmsg(db))
                print("Chyba při vytváření tabulky: \(errMsg)")
            }
        } else {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("CREATE TABLE nelze připravit: \(errMsg)")
        }
        sqlite3_finalize(statement)
    }
    
    private func loadRecords() {
        let querySQL = "SELECT symbol, name, date FROM history ORDER BY date DESC;"
        var statement: OpaquePointer? = nil
        records.removeAll()
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                guard let cSymbol = sqlite3_column_text(statement, 0),
                      let cName = sqlite3_column_text(statement, 1)
                else { continue }
                let symbol = String(cString: cSymbol)
                let name = String(cString: cName)
                let dateValue = sqlite3_column_int64(statement, 2)
                let record = TickerRecord(symbol: symbol, name: name, date: dateValue)
                records.append(record)
            }
        } else {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("SELECT nelze připravit: \(errMsg)")
        }
        sqlite3_finalize(statement)
    }
    
    private func deleteRecord(symbol: String) {
        let deleteSQL = "DELETE FROM history WHERE symbol = ?;"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (symbol as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Záznam smazán (symbol = \(symbol)).")
            } else {
                let errMsg = String(cString: sqlite3_errmsg(db))
                print("Chyba při mazání: \(errMsg)")
            }
        } else {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("DELETE nelze připravit: \(errMsg)")
        }
        sqlite3_finalize(statement)
    }
    
    func addHistory(symbol: String, name: String) {
        let sym = symbol.uppercased()
        deleteRecord(symbol: sym)
        let insertSQL = "INSERT INTO history (symbol, name, date) VALUES (?, ?, ?);"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let finalName = name.isEmpty ? sym : name
            let timestamp = Int64(Date().timeIntervalSince1970)
            sqlite3_bind_text(statement, 1, (sym as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (finalName as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 3, timestamp)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Záznam vložen (symbol = \(sym)).")
            } else {
                let errMsg = String(cString: sqlite3_errmsg(db))
                print("Chyba při vkládání záznamu: \(errMsg)")
            }
        } else {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("INSERT nelze připravit: \(errMsg)")
        }
        sqlite3_finalize(statement)
        loadRecords()
    }
}