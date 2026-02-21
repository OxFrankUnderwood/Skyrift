//
//  Weather.swift
//  Skyrift
//

import Foundation

// MARK: - Location

struct WeatherLocation: Identifiable, Codable, Equatable {
    var id: String { "\(latitude),\(longitude)" }
    let name: String
    let latitude: Double
    let longitude: Double
    var isCurrentLocation: Bool = false
}

// MARK: - Current Weather

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int
    let isDay: Int
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
}

// MARK: - Weather Data

struct WeatherData {
    let current: CurrentWeather
    let daily: [DailyForecast]
}

// MARK: - Weather Condition (WMO Codes)

struct WeatherCondition {
    let symbolName: String
    let description: String

    static func from(code: Int, isDay: Bool = true) -> WeatherCondition {
        switch code {
        case 0:
            return WeatherCondition(symbolName: isDay ? "sun.max.fill" : "moon.fill", description: "Açık")
        case 1:
            return WeatherCondition(symbolName: isDay ? "sun.max.fill" : "moon.fill", description: "Çoğunlukla açık")
        case 2:
            return WeatherCondition(symbolName: isDay ? "cloud.sun.fill" : "cloud.moon.fill", description: "Parçalı bulutlu")
        case 3:
            return WeatherCondition(symbolName: "cloud.fill", description: "Kapalı")
        case 45, 48:
            return WeatherCondition(symbolName: "cloud.fog.fill", description: "Sisli")
        case 51, 53, 55:
            return WeatherCondition(symbolName: "cloud.drizzle.fill", description: "Çisenti")
        case 56, 57:
            return WeatherCondition(symbolName: "cloud.sleet.fill", description: "Dondurucu çisenti")
        case 61, 63, 65:
            return WeatherCondition(symbolName: "cloud.rain.fill", description: "Yağmurlu")
        case 66, 67:
            return WeatherCondition(symbolName: "cloud.sleet.fill", description: "Dondurucu yağmur")
        case 71, 73, 75:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "Karlı")
        case 77:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "Kar taneleri")
        case 80, 81, 82:
            return WeatherCondition(symbolName: "cloud.heavyrain.fill", description: "Sağanak yağış")
        case 85, 86:
            return WeatherCondition(symbolName: "cloud.snow.fill", description: "Kar sağanağı")
        case 95:
            return WeatherCondition(symbolName: "cloud.bolt.fill", description: "Fırtınalı")
        case 96, 99:
            return WeatherCondition(symbolName: "cloud.bolt.rain.fill", description: "Dolu ile fırtına")
        default:
            return WeatherCondition(symbolName: "cloud.fill", description: "Bulutlu")
        }
    }
}
