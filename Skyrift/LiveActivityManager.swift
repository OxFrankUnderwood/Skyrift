//
//  LiveActivityManager.swift
//  Skyrift
//
//  Manages Live Activity for weather updates
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<WeatherActivityAttributes>?
    
    private init() {}
    
    // MARK: - Activity Management
    
    /// Live Activity başlat
    func startActivity(
        temperature: Double,
        weatherCode: Int,
        isDay: Bool,
        cityName: String,
        locationId: String
    ) {
        // iOS 16.1+ ve Live Activity destekli mi kontrol et
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities kullanıcı tarafından devre dışı")
            return
        }
        
        // Mevcut activity'yi sonlandır
        endActivity()
        
        let attributes = WeatherActivityAttributes(locationId: locationId)
        let contentState = WeatherActivityAttributes.ContentState(
            temperature: temperature,
            weatherCode: weatherCode,
            isDay: isDay,
            cityName: cityName,
            lastUpdate: Date()
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity başlatıldı: \(cityName)")
        } catch {
            print("❌ Live Activity başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    /// Live Activity güncelle
    func updateActivity(
        temperature: Double,
        weatherCode: Int,
        isDay: Bool,
        cityName: String
    ) async {
        guard let activity = currentActivity else {
            print("⚠️ Güncellenecek Live Activity yok")
            return
        }
        
        let contentState = WeatherActivityAttributes.ContentState(
            temperature: temperature,
            weatherCode: weatherCode,
            isDay: isDay,
            cityName: cityName,
            lastUpdate: Date()
        )
        
        await activity.update(.init(state: contentState, staleDate: nil))
        print("✅ Live Activity güncellendi: \(cityName)")
    }
    
    /// Live Activity sonlandır
    func endActivity() {
        guard let activity = currentActivity else {
            return
        }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ Live Activity sonlandırıldı")
        }
    }
    
    /// Live Activity aktif mi?
    var isActivityActive: Bool {
        currentActivity != nil
    }
    
    // MARK: - Settings
    
    /// Kullanıcı Live Activity'yi etkinleştirdi mi?
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "liveActivityEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "liveActivityEnabled")
            
            if !newValue {
                // Kapatıldıysa aktif activity'yi sonlandır
                endActivity()
            }
        }
    }
}
