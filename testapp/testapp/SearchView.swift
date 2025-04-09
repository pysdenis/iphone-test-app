import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Zadejte ticker nebo název...", text: $viewModel.query)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onSubmit {
                        viewModel.search()
                    }
                    .submitLabel(.search)
                
                if viewModel.loading {
                    ProgressView("Vyhledávám...")
                        .padding()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Zobrazení výsledků
                List(viewModel.results) { tickerItem in
                    // V detailu třeba použijete tickerItem.ticker
                    // Příklad zobrazení
                    VStack(alignment: .leading) {
                        Text(tickerItem.ticker)
                            .font(.headline)
                        if let name = tickerItem.name {
                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Vyhledávání")
        }
    }
}
