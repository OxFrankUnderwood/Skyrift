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
            #if DEBUG
            print("⚠️ Live Activities kullanıcı tarafından devre dışı")
            #endif
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
            #if DEBUG
            print("✅ Live Activity başlatıldı: \(cityName)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Live Activity başlatılamadı: \(error.localizedDescription)")
            #endif
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
            #if DEBUG
            print("⚠️ Güncellenecek Live Activity yok")
            #endif
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
        #if DEBUG
        print("✅ Live Activity güncellendi: \(cityName)")
        #endif
    }
    
    /// Live Activity sonlandır
    func endActivity() {
        guard let activity = currentActivity else {
            return
        }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            #if DEBUG
            print("✅ Live Activity sonlandırıldı")
            #endif
        }
    }
    
    /// Live Activity aktif mi?
    var isActivityActive: Bool {
        currentActivity != nil
    }
    
    // MARK: - Device Support

    /// Bu cihaz Dynamic Island destekliyor mu?
    /// Dynamic Island: iPhone 14 Pro (iPhone15,2) ve sonrası.
    /// iPhone 14 / 14 Plus (iPhone14,7 / iPhone14,8) desteklemiyor.
    static var isDeviceSupported: Bool {
        #if targetEnvironment(simulator)
        return true
        #elseif os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? ""
        // Dynamic Island model tanımlayıcıları "iPhone15" ile başlar (14 Pro) ve üzeridir.
        // Kural: "iPhone{major},{minor}" → major >= 15 → Dynamic Island var.
        if machine.hasPrefix("iPhone"),
           let majorStr = machine.dropFirst("iPhone".count).split(separator: ",").first,
           let major = Int(majorStr) {
            return major >= 15
        }
        return false
        #else
        return false
        #endif
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
