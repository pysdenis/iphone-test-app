import Foundation

// ------------------------
// 1) Modely pro detail a historii
// ------------------------

struct StockInfo: Codable, Equatable {
    let symbol: String
    let name: String?
    let marketCap: Double?
    let exchange: String?
    let homepage: String?
    
    enum CodingKeys: String, CodingKey {
        case symbol = "ticker"
        case name
        case marketCap = "market_cap"
        case exchange = "primary_exchange"
        case homepage = "homepage_url"
    }
}

struct TickerRecord: Identifiable, Equatable {
    let symbol: String
    let name: String
    let date: Int64
    
    var id: String { symbol }
}

// ------------------------
// 2) Modely pro vyhledávání (v2 endpoint)
// ------------------------

/// Jeden vyhledaný ticker z `/v2/reference/tickers`
struct SearchTicker: Codable, Identifiable {
    let ticker: String       // Polygon v2 vrací klíč "ticker"
    let name: String?
    
    // Identifiable protokol
    var id: String { ticker }
}

/// Odpověď z endpointu v2: `/v2/reference/tickers`
struct SearchResponseV2: Codable {
    let status: String
    let count: Int
    let tickers: [SearchTicker]
}
