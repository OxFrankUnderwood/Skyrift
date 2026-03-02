//
//  Weather.swift
//  Skyrift
//

import Foundation

// MARK: - Location

struct WeatherLocation: Identifiable, Codable, Equatable {
    var id: String { isCurrentLocation ? "current-location" : "\(latitude),\(longitude)" }
    let name: String
    let latitude: Double
    let longitude: Double
    var isCurrentLocation: Bool = false
    
    // Sadece şehir adı - ülke olmadan
    var cityName: String {
        // "İstanbul, Türkiye" -> "İstanbul"
        if let firstPart = name.split(separator: ",").first {
            return String(firstPart).trimmingCharacters(in: .whitespaces)
        }
        return name
    }
}

// MARK: - Current Weather

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int // degrees 0-360, 0 = North
    let weatherCode: Int
    let isDay: Int
    
    // Yeni özellikler
    let uvIndex: Double
    let visibility: Double // km
    let pressure: Double // hPa
    let cloudCover: Int // %
    let conditionText: String? // Türkçe hava durumu açıklaması
}

// MARK: - Daily Forecast

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let maxTemp: Double
    let minTemp: Double
    let weatherCode: Int
    let precipitationSum: Double
    let maxWindSpeed: Double
    
    // Yeni özellikler
    let uvIndexMax: Double
    let precipitationProbability: Int // %
    let sunrise: Date
    let sunset: Date
}

// MARK: - Hourly Forecast

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let weatherCode: Int
    let precipitationProbability: Int
    let precipitation: Double
    let windSpeed: Double
    let humidity: Int
}

// MARK: - Weather Data

struct WeatherData {
    let current: CurrentWeather
    let daily: [DailyForecast]
    let hourly: [HourlyForecast]
    
    // Air Quality Data
    let airQuality: AirQuality?
}

// MARK: - Air Quality

struct AirQuality {
    let aqi: Int // Air Quality Index (1-5)
    let pm25: Double // PM2.5 μg/m³
    let pm10: Double // PM10 μg/m³
    let no2: Double // NO2 μg/m³
    let o3: Double // O3 μg/m³
    
    var category: String {
        switch aqi {
        case 1: return "air_quality_good".localized
        case 2: return "air_quality_moderate".localized
        case 3: return "air_quality_moderate".localized
        case 4: return "air_quality_poor".localized
        case 5: return "air_quality_very_poor".localized
        default: return "air_quality_unknown".localized
        }
    }
    
    var color: String {
        switch aqi {
        case 1: return "green"
        case 2: return "yellow"
        case 3: return "yellow"
        case 4: return "orange"
        case 5: return "red"
        default: return "gray"
        }
    }
}

// MARK: - Weather Condition (WMO Codes)

struct WeatherCondition {
    let symbolName: String
    let description: String

    static func from(code: Int, isDay: Bool = true, customText: String? = nil) -> WeatherCondition {
        // Eğer API'den Türkçe text geldiyse onu kullan
        if let text = customText {
            let symbol = symbolForCode(code, isDay: isDay)
            return WeatherCondition(symbolName: symbol, description: text)
        }
        
        // Fallback: Localized stringler
        switch code {
        case 0:
            return WeatherCondition(symbolName: isDay ? "sun.max.fill" : "moon.fill", description: "weather_clear".localized)
        case 1:
            return WeatherCondition(symbolName: isDay ? "sun.max.fill" : "moon.fill", description: "weather_mostly_clear".localized)
        case 2:
            return WeatherCondition(symbolName: isDay ? "cloud.sun.fill" : "cloud.moon.fill", description: "weather_partly_cloudy".localized)
        case 3:
            return WeatherCondition(symbolName: "cloud.fill", description: "weather_overcast".localized)
        case 45, 48:
            return WeatherCondition(symbolName: "cloud.fog.fill", description: "weather_foggy".localized)
        case 51, 53, 55:
            return WeatherCondition(symbolName: "cloud.drizzle.fill", description: "weather_drizzle".localized)
        case 56, 57:
            return WeatherCondition(symbolName: "cloud.sleet.fill", description: "weather_freezing_drizzle".localized)
        case 61, 63, 65:
            return WeatherCondition(symbolName: "cloud.rain.fill", description: "weather_rainy".localized)
        case 66, 67:
            return WeatherCondition(symbolName: "cloud.sleet.fill", description: "weather_freezing_rain".localized)
        case 71, 73, 75:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "weather_snowy".localized)
        case 77:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "weather_snow_grains".localized)
        case 80, 81, 82:
            return WeatherCondition(symbolName: "cloud.heavyrain.fill", description: "weather_rain_showers".localized)
        case 85, 86:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "weather_snow_showers".localized)
        case 95:
            return WeatherCondition(symbolName: "cloud.bolt.fill", description: "weather_thunderstorm".localized)
        case 96, 99:
            return WeatherCondition(symbolName: "cloud.bolt.rain.fill", description: "weather_thunderstorm_hail".localized)
        default:
            return WeatherCondition(symbolName: "cloud.fill", description: "weather_cloudy".localized)
        }
    }
    
    private static func symbolForCode(_ code: Int, isDay: Bool) -> String {
        switch code {
        case 0: return isDay ? "sun.max.fill" : "moon.fill"
        case 1: return isDay ? "sun.max.fill" : "moon.fill"
        case 2: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 56, 57: return "cloud.sleet.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 66, 67: return "cloud.sleet.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 77: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 85, 86: return "cloud.snow.fill"
        case 95: return "cloud.bolt.fill"
        case 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}
