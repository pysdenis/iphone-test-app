import Foundation
import SwiftUI

class DetailViewModel: ObservableObject {
    @Published var stockInfo: StockInfo?
    @Published var currentPrice: Double?
    @Published var loading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "PbnwkWypB_3AdPk2LONdDqVee15iuS2H"
    
    func fetchStock(symbol: String) {
        let sym = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !sym.isEmpty else { return }
        
        self.stockInfo = nil
        self.errorMessage = nil
        self.loading = true
        
        let urlString = "https://api.polygon.io/v3/reference/tickers/\(sym)?apiKey=\(apiKey)"
        
        Task {
            do {
                guard let url = URL(string: urlString) else {
                    throw URLError(.badURL)
                }
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                let decoder = JSONDecoder()
                let result = try decoder.decode(PolygonTickerResponse.self, from: data)
                await MainActor.run {
                    self.stockInfo = result.results
                    self.loading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Nepodařilo se načíst data: \(error.localizedDescription)"
                    self.loading = false
                }
            }
        }
    }
    
    /// Načte denní agregátní data a nastaví aktuální cenu podle zavírací ceny (c)
    func fetchCurrentPrice(for symbol: String) {
        let sym = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !sym.isEmpty else { return }
        
        // Používáme endpoint daily ticker summary (v2)
        let urlString = "https://api.polygon.io/v2/aggs/ticker/\(sym)/prev?adjusted=true&apiKey=\(apiKey)"
        
        Task {
            do {
                guard let url = URL(string: urlString) else {
                    throw URLError(.badURL)
                }
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                let decoder = JSONDecoder()
                let result = try decoder.decode(DailyTickerSummaryResponse.self, from: data)
                if let summary = result.results.first, let closePrice = summary.c {
                    await MainActor.run {
                        self.currentPrice = closePrice
                    }
                } else {
                    throw URLError(.cannotParseResponse)
                }
            } catch {
                await MainActor.run {
                    print("Chyba při načítání aktuální ceny: \(error.localizedDescription)")
                }
            }
        }
    }
}

fileprivate struct PolygonTickerResponse: Codable {
    let results: StockInfo
}

struct DailyTickerSummaryResponse: Codable {
    let ticker: String
    let adjusted: Bool
    let results: [DailyTickerSummary]
    let status: String
}

struct DailyTickerSummary: Codable {
    let v: Int?        // volume
    let vw: Double?    // volume weighted average price
    let o: Double?     // open
    let c: Double?     // close – použijeme tuto hodnotu jako aktuální cenu
    let h: Double?     // high
    let l: Double?     // low
    let t: Int64?      // timestamp
    let n: Int?        // počet transakcí
}
