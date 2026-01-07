import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct MetroAlertAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var stationName: String
        var status: String // "Listening...", "Approaching..."
    }
    
    var targetStation: String
}

// Note: This code would typically reside in a Widget Extension target
@available(iOS 16.1, *)
struct MetroAlertActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MetroAlertAttributes.self) { context in
            // Lock Screen UI
            VStack {
                HStack {
                    Image(systemName: "tram.fill")
                        .foregroundColor(MetroColors.primary)
                    VStack(alignment: .leading) {
                        Text("Approaching \(context.attributes.targetStation)")
                            .font(.headline)
                        Text(context.state.status)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "tram.fill")
                        .foregroundColor(MetroColors.primary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    WaveformView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Target: \(context.attributes.targetStation)")
                        .font(.title3)
                }
            } compactLeading: {
                Image(systemName: "tram.fill")
                    .foregroundColor(MetroColors.primary)
            } compactTrailing: {
                WaveformView().frame(width: 20)
            } minimal: {
                Image(systemName: "tram.fill")
                    .foregroundColor(MetroColors.primary)
            }
        }
    }
}
