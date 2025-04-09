import SwiftUI

@main
struct MyApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                
                NavigationStack {
                    SearchView()
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                
                NavigationStack {
                    DetailView()
                }
                .tabItem {
                    Label("Detail", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                NavigationStack {
                    WatchlistView()
                }
                .tabItem {
                    Label("Watchlist", systemImage: "star.fill")
                }
            }
            .accentColor(.yellow)
            .environmentObject(dataManager)
        }
    }
}