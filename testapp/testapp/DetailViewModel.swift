import Foundation
import SwiftUI

class DetailViewModel: ObservableObject {
    @Published var stockInfo: StockInfo?
    @Published var currentPrice: Double?
    @Published var loading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "YOUR_API_KEY_HERE" // Nahraďte svým API klíčem
    
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
    
    func fetchCurrentPrice(for symbol: String) {
        let sym = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !sym.isEmpty else { return }
        
        let urlString = "https://api.polygon.io/v1/last/stocks/\(sym)?apiKey=\(apiKey)"
        
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
                let result = try decoder.decode(LastTradeResponse.self, from: data)
                await MainActor.run {
                    self.currentPrice = result.last.price
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

struct LastTradeResponse: Codable {
    let last: LastTrade
}

struct LastTrade: Codable {
    let price: Double
}