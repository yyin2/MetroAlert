import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var searchText = ""
    @State private var history: [Station] = []
    @State private var activeStation: Station?
    
    @State private var arrivingStations: Set<Station> = []
    @State private var isFlashing = false
    
    private let historyKey = "station_history"
    
    private var allActiveStations: [Station] {
        Array(audioManager.targetStations.union(arrivingStations))
            .sorted(by: { $0.name < $1.name })
    }
    
    private var filteredStations: [Station] {
        if searchText.isEmpty {
            return history
        } else {
            return StationProvider.allStations.filter { 
                $0.name.contains(searchText) || 
                $0.nameEn.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            MetroColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                searchBar
                recognitionStatusView
                activeAlertsSection
                resultsList
                Spacer()
            }
        }
        .onAppear {
            setupOnAppear()
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
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
    }
    
    private var searchBar: some View {
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
    }
    
    @ViewBuilder
    private var recognitionStatusView: some View {
        if audioManager.isMonitoring && (!audioManager.lastTranscribedText.isEmpty || !audioManager.lastMatchStatus.isEmpty) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(audioManager.isMonitoring ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        Text(audioManager.isMonitoring ? "正在后台监听" : "监听已停止")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(audioManager.isMonitoring ? .green : .secondary)
                            .bold(audioManager.isMonitoring)
                    }
                    Spacer()
                    Text("实时语音识别")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !audioManager.lastTranscribedText.isEmpty {
                    Text("\"\(audioManager.lastTranscribedText)\"")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                } else {
                    Text("等待环境语音匹配...")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gray)
                        .padding(.vertical, 4)
                }
                
                if !audioManager.lastMatchStatus.isEmpty {
                    HStack {
                        Circle()
                            .fill(audioManager.lastMatchStatus.contains("成功") ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(audioManager.lastMatchStatus)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var activeAlertsSection: some View {
        let activeList = allActiveStations
        if !activeList.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("当前提醒")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(activeList) { active in
                            activeAlertCard(for: active)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private func activeAlertCard(for active: Station) -> some View {
        let isArriving = arrivingStations.contains(active)
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(active.name)
                        .font(.headline)
                        .bold()
                        .foregroundColor(isArriving ? .red : MetroColors.primary)
                    Text(isArriving ? "目的地即将到站！" : active.line)
                        .font(.caption)
                        .foregroundColor(isArriving ? .red : .secondary)
                        .bold(isArriving)
                }
                Spacer()
                if isArriving {
                    Image(systemName: "bell.and.waves.left.and.right.fill")
                        .foregroundColor(.red)
                        .symbolEffect(.bounce, options: .repeating)
                } else {
                    WaveformView()
                }
            }
            
            Button(action: {
                if isArriving {
                    withAnimation {
                        arrivingStations.remove(active)
                        NotificationManager.shared.stopAlertVibration()
                    }
                } else {
                    audioManager.removeTargetStation(active)
                    NotificationManager.shared.stopLiveActivity(for: active.name)
                }
            }) {
                Text(isArriving ? "知道啦" : "停止提醒")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(isArriving ? Color.green.opacity(0.8) : Color.red.opacity(0.6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 200)
        .background(isArriving ? Color.red.opacity(isFlashing ? 0.3 : 0.1) : Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isArriving ? Color.red : MetroColors.primary.opacity(0.3), lineWidth: isArriving ? 2 : 1)
                .opacity(isArriving && isFlashing ? 1 : 0.5)
        )
        .scaleEffect(isArriving && isFlashing ? 1.05 : 1.0)
    }
    
    private var resultsList: some View {
        VStack(alignment: .leading) {
            Text(searchText.isEmpty ? "搜索历史" : "搜索结果")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    let results = filteredStations
                    if results.isEmpty && !searchText.isEmpty {
                        Text("未找到相关车站")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    ForEach(results) { station in
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
    }
    
    // MARK: - Logic
    
    private func setupOnAppear() {
        NotificationManager.shared.requestPermissions()
        audioManager.onMatchFound = { station in
            withAnimation(.easeInOut(duration: 0.5)) {
                _ = arrivingStations.insert(station)
            }
            NotificationManager.shared.triggerArrivedNotification(stationName: station.name)
            NotificationManager.shared.stopLiveActivity(for: station.name)
            
            // Auto-stop after 60 seconds if user doesn't dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                withAnimation {
                    if arrivingStations.contains(station) {
                        _ = arrivingStations.remove(station)
                        NotificationManager.shared.stopAlertVibration()
                    }
                }
            }
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            isFlashing = true
        }
        
        loadHistory()
    }
    
    private func startReminder(for station: Station) {
        withAnimation {
            audioManager.addTargetStation(station)
            NotificationManager.shared.startLiveActivity(for: station.name)
            
            // Add to history if not exists, or move to top
            history.removeAll { $0.id == station.id || $0.name == station.name }
            history.insert(station, at: 0)
            if history.count > 15 { history.removeLast() }
            saveHistory()
            
            searchText = "" // Clear search after selection
            dismissKeyboard()
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
