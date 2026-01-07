import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var searchText = ""
    @State private var history: [Station] = [
        Station(name: "People's Square", line: "Line 1/2/8"),
        Station(name: "Xujiahui", line: "Line 1/9/11")
    ]
    @State private var activeStation: Station?
    
    var body: some View {
        ZStack {
            MetroColors.background.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    Text("MetroAlert")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "tram.fill")
                        .foregroundColor(MetroColors.primary)
                        .font(.title)
                }
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search destination...", text: $searchText)
                        .foregroundColor(.white)
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
                                Text("Listening for:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(active.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(MetroColors.primary)
                            }
                            Spacer()
                            WaveformView()
                        }
                        
                        Button(action: {
                            audioManager.stopMonitoring()
                            NotificationManager.shared.stopLiveActivity()
                            activeStation = nil
                        }) {
                            Text("Stop Reminder")
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
                
                // History List
                VStack(alignment: .leading) {
                    Text("History")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(history.filter { searchText.isEmpty || $0.name.contains(searchText) }) { station in
                                StationRow(station: station) {
                                    startReminder(for: station)
                                } onDelete: {
                                    history.removeAll { $0.id == station.id }
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
        }
    }
    
    private func startReminder(for station: Station) {
        withAnimation {
            activeStation = station
            audioManager.startMonitoring(for: station)
            NotificationManager.shared.startLiveActivity(for: station.name)
            // Add to history if not exists
            if !history.contains(where: { $0.name == station.name }) {
                history.insert(station, at: 0)
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
                Text(station.line)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: onSelect) {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(MetroColors.primary)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
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
