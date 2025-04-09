import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if !dataManager.records.isEmpty {
                    List(dataManager.records) { record in
                        NavigationLink(destination: DetailView(initialTicker: record.symbol)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(record.symbol)
                                        .font(.headline)
                                    if !record.name.isEmpty && record.name != record.symbol {
                                        Text(record.name)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text(formattedDate(timestamp: record.date))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text("Žádné tickery ve watchlistu.")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Watchlist")
        }
    }
    
    private func formattedDate(timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}