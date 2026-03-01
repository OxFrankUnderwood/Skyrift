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
        weatherCode: Int,
        isDay: Int,
        cityName: String,
        maxTemp: Double,
        minTemp: Double
    ) {
        guard let defaults = userDefaults else { return }
        
        let data: [String: Any] = [
            "temperature": temperature,
            "weatherCode": weatherCode,
            "isDay": isDay,
            "cityName": cityName,
            "maxTemp": maxTemp,
            "minTemp": minTemp,
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
        weatherCode: Int,
        isDay: Bool,
        cityName: String,
        maxTemp: Double,
        minTemp: Double
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
        
        return (
            temperature: temperature,
            weatherCode: weatherCode,
            isDay: isDay == 1,
            cityName: cityName,
            maxTemp: maxTemp,
            minTemp: minTemp
        )
    }
}
