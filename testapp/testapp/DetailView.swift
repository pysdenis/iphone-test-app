//
//  DetailView.swift
//  testapp
//
//  Created by Denis Pyš on 02.04.2025.
//


import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel = DetailViewModel()
    @State private var symbol: String = ""
    @State private var showSafari: Bool = false
    @State private var selectedURL: URL? = nil
    @EnvironmentObject private var dataManager: DataManager
    
    // Inicializace s tickerem (např. při výběru z vyhledávání nebo watchlistu)
    init(initialTicker: String? = nil) {
        if let ticker = initialTicker {
            _symbol = State(initialValue: ticker)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Zadejte ticker (např. AAPL)", text: $symbol)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.characters)
            
            Button(action: {
                viewModel.fetchStock(symbol: symbol)
            }) {
                Text("Načíst data")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(symbol.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.loading)
            
            if viewModel.loading {
                HStack {
                    ProgressView()
                    Text("Načítám...")
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            if let info = viewModel.stockInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Název: **\(info.name ?? "-")**")
                    Text("Symbol: \(info.symbol)")
                    if let marketCap = info.marketCap {
                        Text("Market Cap: \(marketCap, format: .number.notation(.compactName))")
                    }
                    if let exchange = info.exchange {
                        Text("Burza: \(exchange)")
                    }
                    if let price = viewModel.currentPrice {
                        Text("Aktuální cena: \(price, specifier: "%.2f") USD")
                            .foregroundColor(.yellow)
                    }
                    
                    Button("Obnovit cenu") {
                        viewModel.fetchCurrentPrice(for: info.symbol)
                    }
                    .buttonStyle(.bordered)
                    
                    if let homepage = info.homepage, let url = URL(string: homepage) {
                        Button("Otevřít web společnosti") {
                            selectedURL = url
                            showSafari = true
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .navigationTitle(viewModel.stockInfo?.symbol ?? "Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            if let url = selectedURL {
                SafariView(url: url)
            }
        }
        .onChange(of: viewModel.stockInfo) { newInfo in
            if let info = newInfo {
                dataManager.addHistory(symbol: info.symbol, name: info.name ?? "")
                viewModel.fetchCurrentPrice(for: info.symbol)
            }
        }
    }
}