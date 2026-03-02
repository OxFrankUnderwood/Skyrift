//
//  WidgetDataManager.swift
//  Skyrift
//
//  Manages data sharing between app and widget
//

import Foundation
import WidgetKit

struct WidgetDataManager {
    static let shared = WidgetDataManager()
    
    // App Group ID - Her iki target'te de aynı olmalı
    private let appGroupID = "group.com.skyrift.weather"
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    // MARK: - Save Weather Data
    
    func saveWeatherForWidget(
        temperature: Double,
        apparentTemperature: Double = 0,
        weatherCode: Int,
        isDay: Int,
        cityName: String,
        maxTemp: Double,
        minTemp: Double,
        humidity: Int = 0,
        windSpeed: Double = 0,
        pressure: Double = 0,
        uvIndex: Double = 0,
        hourlyForecasts: [[String: Any]] = []
    ) {
        guard let defaults = userDefaults else { return }

        let data: [String: Any] = [
            "temperature": temperature,
            "apparentTemperature": apparentTemperature,
            "weatherCode": weatherCode,
            "isDay": isDay,
            "cityName": cityName,
            "maxTemp": maxTemp,
            "minTemp": minTemp,
            "humidity": humidity,
            "windSpeed": windSpeed,
            "pressure": pressure,
            "uvIndex": uvIndex,
            "hourlyForecasts": hourlyForecasts,
            "lastUpdate": Date().timeIntervalSince1970
        ]
        
        defaults.set(data, forKey: "widgetWeatherData")
        defaults.synchronize()
        
        // Widget'ı güncelle
        WidgetCenter.shared.reloadAllTimelines()
        
        print("✅ Widget verisi kaydedildi: \(cityName) \(Int(temperature))°")
    }
    
    // MARK: - Load Weather Data
    
    func loadWeatherForWidget() -> (
        temperature: Double,
        apparentTemperature: Double,
        weatherCode: Int,
        isDay: Bool,
        cityName: String,
        maxTemp: Double,
        minTemp: Double,
        humidity: Int,
        windSpeed: Double,
        pressure: Double,
        uvIndex: Double,
        hourlyForecasts: [[String: Any]]
    )? {
        guard let defaults = userDefaults,
              let data = defaults.dictionary(forKey: "widgetWeatherData") else {
            return nil
        }
        
        guard let temperature = data["temperature"] as? Double,
              let weatherCode = data["weatherCode"] as? Int,
              let isDay = data["isDay"] as? Int,
              let cityName = data["cityName"] as? String,
              let maxTemp = data["maxTemp"] as? Double,
              let minTemp = data["minTemp"] as? Double else {
            return nil
        }

        // Ek veriler - opsiyonel
        let apparentTemperature = data["apparentTemperature"] as? Double ?? temperature
        let humidity = data["humidity"] as? Int ?? 0
        let windSpeed = data["windSpeed"] as? Double ?? 0
        let pressure = data["pressure"] as? Double ?? 0
        let uvIndex = data["uvIndex"] as? Double ?? 0
        let hourlyForecasts = data["hourlyForecasts"] as? [[String: Any]] ?? []

        return (
            temperature: temperature,
            apparentTemperature: apparentTemperature,
            weatherCode: weatherCode,
            isDay: isDay == 1,
            cityName: cityName,
            maxTemp: maxTemp,
            minTemp: minTemp,
            humidity: humidity,
            windSpeed: windSpeed,
            pressure: pressure,
            uvIndex: uvIndex,
            hourlyForecasts: hourlyForecasts
        )
    }
}
