//
//  SkyriftWidget.swift
//  SkyriftWidget
//
//  Weather widget for Skyrift
//

import WidgetKit
import SwiftUI

// MARK: - Widget Localization Helper (Optimized)

extension String {
    var widgetLocalized: String {
        // ⚡ Cache bundle lookup
        return WidgetLocalizationCache.shared.localize(self)
    }
}

// Singleton cache for bundle lookups
final class WidgetLocalizationCache {
    static let shared = WidgetLocalizationCache()
    
    private var cachedBundle: Bundle?
    private var cachedLanguageCode: String?
    
    private init() {
        setupBundle()
    }
    
    private func setupBundle() {
        // App Group'tan kullanıcının seçtiği dili al
        if let userDefaults = UserDefaults(suiteName: "group.com.skyrift.weather"),
           let languageCode = userDefaults.string(forKey: "selectedLanguage") {
            // Bundle'ı cache'le
            if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
               let bundle = Bundle(path: bundlePath) {
                cachedBundle = bundle
                cachedLanguageCode = languageCode
                return
            }
        }
        
        // Fallback
        cachedBundle = .main
    }
    
    func localize(_ key: String) -> String {
        guard let bundle = cachedBundle else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: key, comment: "")
    }
}

// MARK: - Widget Entry

// Basit saatlik veri yapısı
struct HourlyWeatherData: Codable {
    let hour: String
    let temperature: Double
    let weatherCode: Int
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let weatherCode: Int
    let isDay: Bool
    let cityName: String
    let maxTemp: Double
    let minTemp: Double
    
    // Ek bilgiler
    var apparentTemperature: Double = 0
    var humidity: Int = 0
    var windSpeed: Double = 0
    var pressure: Double = 0
    var uvIndex: Double = 0
    
    // Saatlik tahminler (ileri 6 saat)
    var hourlyForecasts: [HourlyWeatherData] = []
}

// MARK: - Timeline Provider

struct WeatherTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        // ⚡ Minimal placeholder - memory tasarrufu
        WeatherEntry(
            date: Date(),
            temperature: 22,
            weatherCode: 0,
            isDay: true,
            cityName: "İstanbul",
            maxTemp: 25,
            minTemp: 18,
            humidity: 45,
            windSpeed: 12,
            pressure: 1013,
            uvIndex: 5,
            hourlyForecasts: [] // ⚡ Boş bırak, placeholder'da gereksiz
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = fetchWeatherData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        // App Group'tan gerçek veriyi al
        let entry = fetchWeatherData()
        
        // 15 dakikada bir güncelle
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func fetchWeatherData() -> WeatherEntry {
        // WidgetDataManager üzerinden App Group'tan veriyi al
        if let weatherData = WidgetDataManager.shared.loadWeatherForWidget() {
            // Saatlik verileri parse et
            let hourlyForecasts = weatherData.hourlyForecasts.compactMap { dict -> HourlyWeatherData? in
                guard let hour = dict["hour"] as? String,
                      let temp = dict["temperature"] as? Double,
                      let code = dict["weatherCode"] as? Int else {
                    return nil
                }
                return HourlyWeatherData(hour: hour, temperature: temp, weatherCode: code)
            }
            
            return WeatherEntry(
                date: Date(),
                temperature: weatherData.temperature,
                weatherCode: weatherData.weatherCode,
                isDay: weatherData.isDay,
                cityName: weatherData.cityName,
                maxTemp: weatherData.maxTemp,
                minTemp: weatherData.minTemp,
                apparentTemperature: weatherData.apparentTemperature,
                humidity: weatherData.humidity,
                windSpeed: weatherData.windSpeed,
                pressure: weatherData.pressure,
                uvIndex: weatherData.uvIndex,
                hourlyForecasts: hourlyForecasts
            )
        }
        
        // Veri yoksa placeholder dön
        return WeatherEntry(
            date: Date(),
            temperature: 22,
            weatherCode: 0,
            isDay: true,
            cityName: "İstanbul",
            maxTemp: 25,
            minTemp: 18,
            humidity: 45,
            windSpeed: 12,
            pressure: 1013,
            uvIndex: 5,
            hourlyForecasts: [
                HourlyWeatherData(hour: "14:00", temperature: 22, weatherCode: 0),
                HourlyWeatherData(hour: "15:00", temperature: 23, weatherCode: 0),
                HourlyWeatherData(hour: "16:00", temperature: 24, weatherCode: 1),
                HourlyWeatherData(hour: "17:00", temperature: 23, weatherCode: 1),
                HourlyWeatherData(hour: "18:00", temperature: 21, weatherCode: 2),
                HourlyWeatherData(hour: "19:00", temperature: 19, weatherCode: 2)
            ]
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
        // İçerik - arka plan containerBackground'da olacak
        VStack(spacing: 0) {
            // Üst kısım - Şehir adı
            Text(entry.cityName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.top, 12)
                .padding(.horizontal, 12)
            
            Spacer(minLength: 0)
            
            // Orta kısım - Ana bilgi
            VStack(spacing: 6) {
                // Hava durumu ikonu
                Image(systemName: condition.symbolName)
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                
                // Sıcaklık
                Text("\(Int(entry.temperature.rounded()))°")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer(minLength: 0)
            
            // Alt kısım - Min/Max
            HStack(spacing: 0) {
                // Min
                HStack(spacing: 3) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("\(Int(entry.minTemp.rounded()))°")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // Ayırıcı
                Text("  •  ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                // Max
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("\(Int(entry.maxTemp.rounded()))°")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: WeatherEntry
    
    var condition: WeatherConditionWidget {
        WeatherConditionWidget.from(code: entry.weatherCode, isDay: entry.isDay)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Sol taraf - Ana bilgiler (63% genişlik)
                VStack(alignment: .leading, spacing: 0) {
                    // Şehir adı
                    Text(entry.cityName)
                        .font(.system(size: geometry.size.height * 0.14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .padding(.top, geometry.size.height * 0.12)
                    
                    Spacer()
                    
                    // İkon ve sıcaklık - ortalanmış
                    HStack(spacing: geometry.size.width * 0.02) {
                        Image(systemName: condition.symbolName)
                            .font(.system(size: geometry.size.height * 0.38))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                        
                        Text("\(Int(entry.temperature.rounded()))°")
                            .font(.system(size: geometry.size.height * 0.45, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    // Açıklama
                    Text(condition.description)
                        .font(.system(size: geometry.size.height * 0.12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.bottom, geometry.size.height * 0.12)
                }
                .frame(width: geometry.size.width * 0.63)
                .padding(.leading, geometry.size.width * 0.055)
                
                // Sağ taraf - Min/Max kartları (32% genişlik)
                VStack(spacing: geometry.size.height * 0.06) {
                    // Min kartı
                    HStack(spacing: geometry.size.width * 0.015) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: geometry.size.height * 0.16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("\(Int(entry.minTemp.rounded()))°")
                                .font(.system(size: geometry.size.height * 0.24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("widget_min".widgetLocalized)
                                .font(.system(size: geometry.size.height * 0.095, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.4)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.height * 0.12)
                            .fill(.white.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.height * 0.12)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    
                    // Max kartı
                    HStack(spacing: geometry.size.width * 0.015) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: geometry.size.height * 0.16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("\(Int(entry.maxTemp.rounded()))°")
                                .font(.system(size: geometry.size.height * 0.24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("widget_max".widgetLocalized)
                                .font(.system(size: geometry.size.height * 0.095, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.4)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.height * 0.12)
                            .fill(.white.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.height * 0.12)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                }
                .frame(width: geometry.size.width * 0.32)
                .padding(.trailing, geometry.size.width * 0.045)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: WeatherEntry
    
    var condition: WeatherConditionWidget {
        WeatherConditionWidget.from(code: entry.weatherCode, isDay: entry.isDay)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst kısım - Ana bilgi
            VStack(spacing: 8) {
                Text(entry.cityName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.top, 16)

                HStack(spacing: 12) {
                    Image(systemName: condition.symbolName)
                        .font(.system(size: 52))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)

                    Text("\(Int(entry.temperature.rounded()))°")
                        .font(.system(size: 52, weight: .thin, design: .rounded))
                        .foregroundStyle(.white)

                    Text(condition.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 16)

            // Saatlik grafik
            if !entry.hourlyForecasts.isEmpty {
                VStack(spacing: 8) {
                    Text("widget_hourly_forecast".widgetLocalized)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    HourlyForecastChart(forecasts: entry.hourlyForecasts)
                        .frame(height: 130)
                }
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Inline Widget (Medium, transparent background)

struct InlineWeatherWidgetView: View {
    let entry: WeatherEntry

    var condition: WeatherConditionWidget {
        WeatherConditionWidget.from(code: entry.weatherCode, isDay: entry.isDay)
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Sol: hava ikonu
                Image(systemName: condition.symbolName)
                    .font(.system(size: geo.size.height * 0.50))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
                    .frame(width: geo.size.width * 0.30)

                // Dikey çizgi
                Rectangle()
                    .fill(.primary.opacity(0.25))
                    .frame(width: 1)
                    .padding(.vertical, geo.size.height * 0.18)

                // Sağ: bilgiler
                VStack(alignment: .leading, spacing: geo.size.height * 0.05) {
                    // Sıcaklık + Today badge
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(Int(entry.temperature.rounded()))°")
                            .font(.system(size: geo.size.height * 0.44, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("widget_today".widgetLocalized)
                            .font(.system(size: geo.size.height * 0.13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.red, in: RoundedRectangle(cornerRadius: 4))
                    }

                    // Açıklama satırı
                    Text(String(
                        format: "widget_inline_desc".widgetLocalized,
                        condition.description,
                        "\(Int(entry.apparentTemperature.rounded()))°"
                    ))
                    .font(.system(size: geo.size.height * 0.145))
                    .foregroundStyle(.primary.opacity(0.75))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, geo.size.width * 0.05)
                .padding(.trailing, geo.size.width * 0.03)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Inline Widget Configuration

struct SkyriftInlineWidget: Widget {
    let kind: String = "SkyriftInlineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherTimelineProvider()) { entry in
            InlineWeatherWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
                .widgetURL(URL(string: "skyrift://weather"))
        }
        .configurationDisplayName("Skyrift Inline")
        .description("Anlık sıcaklık ve hissedilen değer")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Hourly Forecast Chart (Optimized)

struct HourlyForecastChart: View {
    let forecasts: [HourlyWeatherData]
    
    var body: some View {
        // ⚡ Limit to 6 items max to reduce memory
        let displayForecasts = Array(forecasts.prefix(6))
        
        HStack(spacing: 8) {
            ForEach(Array(displayForecasts.enumerated()), id: \.offset) { index, forecast in
                VStack(spacing: 6) {
                    // Sıcaklık
                    Text("\(Int(forecast.temperature.rounded()))°")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Grafik çubuğu - Simplified
                    RoundedRectangle(cornerRadius: 3)
                        .fill(temperatureColor(forecast.temperature))
                        .frame(height: barHeight(for: forecast.temperature))
                        .frame(maxHeight: 50) // ⚡ Fixed max height
                    
                    // Hava durumu ikonu (küçük)
                    Image(systemName: weatherIcon(for: forecast.weatherCode))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(height: 12)
                    
                    // Saat
                    Text(forecast.hour)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // ⚡ Simplified bar height calculation
    private func barHeight(for temp: Double) -> CGFloat {
        let temps = forecasts.map { $0.temperature }
        guard let minTemp = temps.min(), let maxTemp = temps.max() else {
            return 25
        }
        
        let range = maxTemp - minTemp
        guard range > 0 else { return 25 }
        
        let normalized = (temp - minTemp) / range
        return 15 + (35 * normalized)
    }
    
    // ⚡ Solid colors instead of gradients
    private func temperatureColor(_ temp: Double) -> Color {
        switch temp {
        case ..<0: return Color.blue.opacity(0.7)
        case 0..<10: return Color.cyan.opacity(0.7)
        case 10..<20: return Color.green.opacity(0.7)
        case 20..<30: return Color.yellow.opacity(0.7)
        default: return Color.red.opacity(0.7)
        }
    }
    
    // Hava durumu kodu için ikon
    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0, 1: return "sun.max.fill"
        case 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...57: return "cloud.drizzle.fill"
        case 61...67: return "cloud.rain.fill"
        case 71...86: return "cloud.snow.fill"
        case 95...99: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
}

// MARK: - Helper Functions

func gradientColors(for code: Int, isDay: Bool) -> [Color] {
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

// MARK: - Weather Condition Helper

struct WeatherConditionWidget {
    let symbolName: String
    let description: String
    
    static func from(code: Int, isDay: Bool) -> WeatherConditionWidget {
        switch code {
        case 0, 1:
            return WeatherConditionWidget(
                symbolName: isDay ? "sun.max.fill" : "moon.fill",
                description: "weather_clear".widgetLocalized
            )
        case 2:
            return WeatherConditionWidget(
                symbolName: isDay ? "cloud.sun.fill" : "cloud.moon.fill",
                description: "weather_partly_cloudy".widgetLocalized
            )
        case 3:
            return WeatherConditionWidget(
                symbolName: "cloud.fill",
                description: "weather_cloudy".widgetLocalized
            )
        case 45, 48:
            return WeatherConditionWidget(
                symbolName: "cloud.fog.fill",
                description: "weather_foggy".widgetLocalized
            )
        case 51...57:
            return WeatherConditionWidget(
                symbolName: "cloud.drizzle.fill",
                description: "weather_drizzle".widgetLocalized
            )
        case 61...67:
            return WeatherConditionWidget(
                symbolName: "cloud.rain.fill",
                description: "weather_rainy".widgetLocalized
            )
        case 71...86:
            return WeatherConditionWidget(
                symbolName: "cloud.snow.fill",
                description: "weather_snowy".widgetLocalized
            )
        case 95...99:
            return WeatherConditionWidget(
                symbolName: "cloud.bolt.fill",
                description: "weather_thunderstorm".widgetLocalized
            )
        default:
            return WeatherConditionWidget(
                symbolName: "cloud.fill",
                description: "weather_cloudy".widgetLocalized
            )
        }
    }
}

// MARK: - Widget Configuration

struct SkyriftWidget: Widget {
    let kind: String = "SkyriftWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                SkyriftWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        // Animasyonlu arka plan
                        WidgetBackgroundView(weatherCode: entry.weatherCode, isDay: entry.isDay)
                    }
                    .widgetURL(URL(string: "skyrift://weather"))
            } else {
                ZStack {
                    // iOS 16 ve öncesi için arka plan
                    WidgetBackgroundView(weatherCode: entry.weatherCode, isDay: entry.isDay)
                    
                    SkyriftWidgetView(entry: entry)
                }
                .widgetURL(URL(string: "skyrift://weather"))
            }
        }
        .configurationDisplayName("Hava Durumu")
        .description("Anlık hava durumu bilgisi")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Background View (Optimized - Reduced Memory)

struct WidgetBackgroundView: View {
    let weatherCode: Int
    let isDay: Bool
    
    var body: some View {
        // ⚡ Simple gradient only - no complex animations
        LinearGradient(
            colors: gradientColors(for: weatherCode, isDay: isDay),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
        cityName: "İstanbul",
        maxTemp: 25,
        minTemp: 18,
        humidity: 45,
        windSpeed: 12,
        pressure: 1013,
        uvIndex: 5,
        hourlyForecasts: []
    )
    WeatherEntry(
        date: Date().addingTimeInterval(3600),
        temperature: 18,
        weatherCode: 61,
        isDay: false,
        cityName: "Ankara",
        maxTemp: 20,
        minTemp: 15,
        humidity: 60,
        windSpeed: 8,
        pressure: 1010,
        uvIndex: 0,
        hourlyForecasts: []
    )
}

#Preview("Medium", as: .systemMedium) {
    SkyriftWidget()
} timeline: {
    WeatherEntry(
        date: Date(),
        temperature: 22,
        weatherCode: 0,
        isDay: true,
        cityName: "İstanbul",
        maxTemp: 25,
        minTemp: 18,
        humidity: 45,
        windSpeed: 12,
        pressure: 1013,
        uvIndex: 5,
        hourlyForecasts: []
    )
}

#Preview("Large", as: .systemLarge) {
    SkyriftWidget()
} timeline: {
    WeatherEntry(
        date: Date(),
        temperature: 22,
        weatherCode: 0,
        isDay: true,
        cityName: "İstanbul",
        maxTemp: 25,
        minTemp: 18,
        humidity: 45,
        windSpeed: 12,
        pressure: 1013,
        uvIndex: 5,
        hourlyForecasts: [
            HourlyWeatherData(hour: "14:00", temperature: 20, weatherCode: 0),
            HourlyWeatherData(hour: "15:00", temperature: 22, weatherCode: 0),
            HourlyWeatherData(hour: "16:00", temperature: 24, weatherCode: 1),
            HourlyWeatherData(hour: "17:00", temperature: 25, weatherCode: 1),
            HourlyWeatherData(hour: "18:00", temperature: 23, weatherCode: 2),
            HourlyWeatherData(hour: "19:00", temperature: 20, weatherCode: 2)
        ]
    )
}


