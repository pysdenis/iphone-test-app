//
//  HomeView.swift
//  testapp
//
//  Created by Denis Pyš on 02.04.2025.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("favoriteTicker") private var favoriteTicker: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Vítejte v StocksApp!")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                    .padding(.top)
                
                if !favoriteTicker.isEmpty {
                    Text("Oblíbený ticker: **\(favoriteTicker)**")
                        .font(.title2)
                }
                
                if !dataManager.records.isEmpty {
                    Text("Historie zobrazených tickerů:")
                        .font(.headline)
                    List(dataManager.records) { record in
                        NavigationLink(destination: DetailView(initialTicker: record.symbol)) {
                            VStack(alignment: .leading) {
                                Text(record.symbol)
                                    .font(.headline)
                                if !record.name.isEmpty && record.name != record.symbol {
                                    Text(record.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                } else {
                    Text("Zatím jste nevyhledali žádný ticker.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Home")
        }
    }
}