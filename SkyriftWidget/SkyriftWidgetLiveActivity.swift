//
//  SkyriftWidgetLiveActivity.swift
//  SkyriftWidget
//
//  Live Activity for weather updates
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget
// Note: WeatherActivityAttributes is now in a shared file

struct SkyriftWeatherLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherActivityAttributes.self) { context in
            // Lock Screen / Banner görünümü
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded - Tam açılmış görünüm
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: weatherIcon(for: context.state.weatherCode, isDay: context.state.isDay))
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                        
                        Text("\(Int(context.state.temperature.rounded()))°")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.cityName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(weatherDescription(for: context.state.weatherCode))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(context.state.cityName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(timeString(from: context.state.lastUpdate))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 8)
                }
                
            } compactLeading: {
                // Compact Leading - Sol taraf
                Image(systemName: weatherIcon(for: context.state.weatherCode, isDay: context.state.isDay))
                    .symbolRenderingMode(.hierarchical)
            } compactTrailing: {
                // Compact Trailing - Sağ taraf
                Text("\(Int(context.state.temperature.rounded()))°")
                    .font(.caption)
                    .fontWeight(.semibold)
            } minimal: {
                // Minimal - En küçük görünüm
                Image(systemName: weatherIcon(for: context.state.weatherCode, isDay: context.state.isDay))
                    .symbolRenderingMode(.hierarchical)
            }
            .keylineTint(.cyan)
        }
    }
    
    // MARK: - Lock Screen View
    
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<WeatherActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            // Sol - İkon ve sıcaklık
            HStack(spacing: 12) {
                Image(systemName: weatherIcon(for: context.state.weatherCode, isDay: context.state.isDay))
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.cyan)
                
                Text("\(Int(context.state.temperature.rounded()))°")
                    .font(.system(size: 36, weight: .thin, design: .rounded))
            }
            
            Spacer()
            
            // Sağ - Detaylar
            VStack(alignment: .trailing, spacing: 4) {
                Text(context.state.cityName)
                    .font(.headline)
                
                Text(weatherDescription(for: context.state.weatherCode))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(timeString(from: context.state.lastUpdate))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .activityBackgroundTint(Color.cyan.opacity(0.2))
        .activitySystemActionForegroundColor(.cyan)
    }
    
    // MARK: - Helper Functions
    
    private func weatherIcon(for code: Int, isDay: Bool) -> String {
        switch code {
        case 0, 1: return isDay ? "sun.max.fill" : "moon.fill"
        case 2: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...57: return "cloud.drizzle.fill"
        case 61...67: return "cloud.rain.fill"
        case 71...86: return "cloud.snow.fill"
        case 95...99: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
    
    private func weatherDescription(for code: Int) -> String {
        // Widget Extension için lokalize edilmiş metin
        let key: String
        switch code {
        case 0, 1: key = "weather_clear"
        case 2: key = "weather_partly_cloudy"
        case 3: key = "weather_overcast"
        case 45, 48: key = "weather_foggy"
        case 51...57: key = "weather_drizzle"
        case 61...67: key = "weather_rainy"
        case 71...86: key = "weather_snowy"
        case 95...99: key = "weather_thunderstorm"
        default: key = "weather_cloudy"
        }
        
        return NSLocalizedString(key, comment: "")
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Notification", as: .content, using: WeatherActivityAttributes(locationId: "test")) {
    SkyriftWeatherLiveActivity()
} contentStates: {
    WeatherActivityAttributes.ContentState(
        temperature: 22,
        weatherCode: 0,
        isDay: true,
        cityName: "İstanbul",
        lastUpdate: Date()
    )
    
    WeatherActivityAttributes.ContentState(
        temperature: 15,
        weatherCode: 61,
        isDay: false,
        cityName: "Ankara",
        lastUpdate: Date()
    )
}
