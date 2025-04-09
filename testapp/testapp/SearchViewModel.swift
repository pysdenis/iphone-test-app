import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [SearchTicker] = []
    @Published var loading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "YOUR_API_KEY_HERE" // Nahraďte svým API klíčem
    
    func search() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        loading = true
        errorMessage = nil
        
        let urlString = "https://api.polygon.io/v3/reference/tickers?search=\(trimmed)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Špatná URL"
            self.loading = false
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                await MainActor.run {
                    self.results = searchResponse.results
                    self.loading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Chyba: \(error.localizedDescription)"
                    self.loading = false
                }
            }
        }
    }
}