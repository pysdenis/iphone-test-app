//
//  StockInfo.swift
//  testapp
//
//  Created by Denis Pyš on 02.04.2025.
//


import Foundation

// Detail informace o tickeru získané z Polygon API.
struct StockInfo: Codable, Equatable {
    let symbol: String         // ticker např. "AAPL"
    let name: String?          // název společnosti
    let marketCap: Double?     // tržní kapitalizace
    let exchange: String?      // primární burza
    let homepage: String?      // URL oficiální webové stránky

    enum CodingKeys: String, CodingKey {
        case symbol = "ticker"
        case name
        case marketCap = "market_cap"
        case exchange = "primary_exchange"
        case homepage = "homepage_url"
    }
}

// Záznam historie – uložený do SQLite databáze.
struct TickerRecord: Identifiable, Equatable {
    let symbol: String
    let name: String
    let date: Int64   // Unix timestamp

    var id: String { symbol }
}

// Model pro vyhledávaný ticker (použito v SearchView).
struct SearchTicker: Codable, Identifiable {
    let symbol: String
    let name: String?
    
    var id: String { symbol }
}

// Odpověď z endpointu vyhledávání.
struct SearchResponse: Codable {
    let results: [SearchTicker]
}