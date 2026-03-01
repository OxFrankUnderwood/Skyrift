//
//  SkyriftWidget.swift
//  SkyriftWidget
//
//  Weather widget for Skyrift
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let weatherCode: Int
    let isDay: Bool
    let cityName: String
    let maxTemp: Double
    let minTemp: Double
}

// MARK: - Timeline Provider

struct WeatherTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            temperature: 22,
            weatherCode: 0,
            isDay: true,
            cityName: "Istanbul",
            maxTemp: 25,
            minTemp: 18
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(
            date: Date(),
            temperature: 22,
            weatherCode: 0,
            isDay: true,
            cityName: "Istanbul",
            maxTemp: 25,
            minTemp: 18
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            // UserDefaults'tan son kaydedilen hava durumu verisini al
            let entry = await fetchWeatherData()
            
            // 30 dakikada bir güncelle
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func fetchWeatherData() async -> WeatherEntry {
        // App Group üzerinden veri paylaşımı yapacağız
        // Şimdilik placeholder data dönelim
        return WeatherEntry(
            date: Date(),
            temperature: 22,
            weatherCode: 0,
            isDay: true,
            cityName: "Istanbul",
            maxTemp: 25,
            minTemp: 18
        )
    }
}

// MARK: - Widget View

struct SkyriftWidgetView: View {
    var entry: WeatherEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: WeatherEntry
    
    var condition: WeatherConditionWidget {
        WeatherConditionWidget.from(code: entry.weatherCode, isDay: entry.isDay)
    }
    
    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: gradientColors(for: entry.weatherCode, isDay: entry.isDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // Şehir adı
                Text(entry.cityName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))
                
                // Hava durumu ikonu
                Image(systemName: condition.symbolName)
                    .font(.system(size: 40))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                
                // Sıcaklık
                Text("\(Int(entry.temperature.rounded()))°")
                    .font(.system(size: 36, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
                
                // Min/Max
                HStack(spacing: 4) {
                    Text("↓\(Int(entry.minTemp.rounded()))°")
                    Text("↑\(Int(entry.maxTemp.rounded()))°")
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
    
    private func gradientColors(for code: Int, isDay: Bool) -> [Color] {
        switch code {
        case 0, 1: // Açık
            return isDay
                ? [Color(red: 1.0, green: 0.75, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.3)]
                : [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.5)]
        case 2, 3: // Bulutlu
            return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.5, green: 0.6, blue: 0.7)]
        case 45, 48: // Sisli
            return [Color(red: 0.6, green: 0.65, blue: 0.7), Color(red: 0.7, green: 0.75, blue: 0.8)]
        case 51...67: // Yağmurlu
            return [Color(red: 0.2, green: 0.4, blue: 0.7), Color(red: 0.3, green: 0.3, blue: 0.6)]
        case 71...86: // Karlı
            return [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.9, blue: 1.0)]
        case 95...99: // Fırtınalı
            return [Color(red: 0.2, green: 0.2, blue: 0.4), Color(red: 0.4, green: 0.3, blue: 0.5)]
        default:
            return [Color.blue, Color.cyan]
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: WeatherEntry
    
    var condition: WeatherConditionWidget {
        WeatherConditionWidget.from(code: entry.weatherCode, isDay: entry.isDay)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors(for: entry.weatherCode, isDay: entry.isDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 20) {
                // Sol taraf - Ana bilgi
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.cityName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Image(systemName: condition.symbolName)
                        .font(.system(size: 50))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                    
                    Text("\(Int(entry.temperature.rounded()))°")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Sağ taraf - Detaylar
                VStack(alignment: .trailing, spacing: 12) {
                    Text(condition.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text("Min")
                                .font(.caption2)
                            Text("\(Int(entry.minTemp.rounded()))°")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Max")
                                .font(.caption2)
                            Text("\(Int(entry.maxTemp.rounded()))°")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding()
        }
    }
    
    private func gradientColors(for code: Int, isDay: Bool) -> [Color] {
        switch code {
        case 0, 1:
            return isDay
                ? [Color(red: 1.0, green: 0.75, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.3)]
                : [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.5)]
        case 2, 3:
            return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.5, green: 0.6, blue: 0.7)]
        case 45, 48:
            return [Color(red: 0.6, green: 0.65, blue: 0.7), Color(red: 0.7, green: 0.75, blue: 0.8)]
        case 51...67:
            return [Color(red: 0.2, green: 0.4, blue: 0.7), Color(red: 0.3, green: 0.3, blue: 0.6)]
        case 71...86:
            return [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.9, blue: 1.0)]
        case 95...99:
            return [Color(red: 0.2, green: 0.2, blue: 0.4), Color(red: 0.4, green: 0.3, blue: 0.5)]
        default:
            return [Color.blue, Color.cyan]
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: WeatherEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack {
                Text("Large Widget")
                    .font(.title)
                    .foregroundStyle(.white)
                Text("Coming Soon")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Weather Condition Helper

struct WeatherConditionWidget {
    let symbolName: String
    let description: String
    
    static func from(code: Int, isDay: Bool) -> WeatherConditionWidget {
        switch code {
        case 0, 1:
            return WeatherConditionWidget(
                symbolName: isDay ? "sun.max.fill" : "moon.fill",
                description: "Clear"
            )
        case 2:
            return WeatherConditionWidget(
                symbolName: isDay ? "cloud.sun.fill" : "cloud.moon.fill",
                description: "Partly Cloudy"
            )
        case 3:
            return WeatherConditionWidget(
                symbolName: "cloud.fill",
                description: "Cloudy"
            )
        case 45, 48:
            return WeatherConditionWidget(
                symbolName: "cloud.fog.fill",
                description: "Foggy"
            )
        case 51...57:
            return WeatherConditionWidget(
                symbolName: "cloud.drizzle.fill",
                description: "Drizzle"
            )
        case 61...67:
            return WeatherConditionWidget(
                symbolName: "cloud.rain.fill",
                description: "Rainy"
            )
        case 71...86:
            return WeatherConditionWidget(
                symbolName: "cloud.snow.fill",
                description: "Snowy"
            )
        case 95...99:
            return WeatherConditionWidget(
                symbolName: "cloud.bolt.fill",
                description: "Thunderstorm"
            )
        default:
            return WeatherConditionWidget(
                symbolName: "cloud.fill",
                description: "Cloudy"
            )
        }
    }
}

// MARK: - Widget Configuration

@main
struct SkyriftWidget: Widget {
    let kind: String = "SkyriftWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherTimelineProvider()) { entry in
            SkyriftWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Skyrift Weather")
        .description("Check the weather at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    SkyriftWidget()
} timeline: {
    WeatherEntry(
        date: Date(),
        temperature: 22,
        weatherCode: 0,
        isDay: true,
        cityName: "Istanbul",
        maxTemp: 25,
        minTemp: 18
    )
}
