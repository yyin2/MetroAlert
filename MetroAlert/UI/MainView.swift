import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var searchText = ""
    @State private var history: [Station] = []
    @State private var activeStation: Station?
    
    private let historyKey = "station_history"
    
    var body: some View {
        ZStack {
            MetroColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("地铁到站提醒")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "tram.fill")
                        .foregroundColor(MetroColors.primary)
                        .font(.title2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索目的地车站...", text: $searchText)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Active Alert Section
                if let active = activeStation {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("正在监听：")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(active.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(MetroColors.primary)
                                Text("\(active.city) · \(active.line)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            WaveformView()
                        }
                        
                        Button(action: {
                            audioManager.stopMonitoring()
                            NotificationManager.shared.stopLiveActivity()
                            activeStation = nil
                        }) {
                            Text("停止提醒")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .glassmorphic()
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Result/History List
                VStack(alignment: .leading) {
                    Text(searchText.isEmpty ? "搜索历史" : "搜索结果")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            let filteredStations = searchText.isEmpty ? history : StationProvider.allStations.filter { 
                                $0.name.contains(searchText) || $0.nameEn.lowercased().contains(searchText.lowercased()) 
                            }
                            
                            if filteredStations.isEmpty && !searchText.isEmpty {
                                Text("未找到相关车站")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                            
                            ForEach(filteredStations) { station in
                                StationRow(station: station) {
                                    startReminder(for: station)
                                } onDelete: {
                                    history.removeAll { $0.id == station.id }
                                    saveHistory()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            NotificationManager.shared.requestPermissions()
            audioManager.onMatchFound = {
                if let station = activeStation {
                    NotificationManager.shared.triggerArrivedNotification(stationName: station.name)
                    NotificationManager.shared.stopLiveActivity()
                }
                activeStation = nil
            }
            loadHistory()
        }
    }
    
    private func startReminder(for station: Station) {
        withAnimation {
            activeStation = station
            audioManager.startMonitoring(for: station)
            NotificationManager.shared.startLiveActivity(for: station.name)
            
            // Add to history if not exists, or move to top
            history.removeAll { $0.id == station.id || $0.name == station.name }
            history.insert(station, at: 0)
            if history.count > 15 { history.removeLast() }
            saveHistory()
            
            searchText = "" // Clear search after selection
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([Station].self, from: data) {
            history = decoded
        }
        
        // Final fallback for empty history
        if history.isEmpty {
            let samples = StationProvider.shanghaiStations
            if samples.count >= 13 {
                history = [samples[12], samples[7]] // People's Square & Xujiahui
                saveHistory()
            }
        }
    }
}

struct StationRow: View {
    let station: Station
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(station.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(station.city) · \(station.line)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: onSelect) {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(MetroColors.primary)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.6))
                    .padding(.leading, 10)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

struct WaveformView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(MetroColors.primary)
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 10...30) : 10)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1), value: isAnimating)
            }
        }
        .onAppear { isAnimating = true }
    }
}
