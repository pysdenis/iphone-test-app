import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var dataManager: DataManager
    
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
                
                List(viewModel.results) { ticker in
                    NavigationLink(destination: DetailView(initialTicker: ticker.symbol)) {
                        VStack(alignment: .leading) {
                            Text(ticker.symbol)
                                .font(.headline)
                            if let name = ticker.name {
                                Text(name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vyhledávání")
        }
    }
}