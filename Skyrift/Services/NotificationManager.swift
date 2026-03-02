//
//  NotificationManager.swift
//  Skyrift
//
//  Manages local weather notifications and background refresh scheduling.
//

import Foundation
import Observation
import UserNotifications

#if os(iOS)
import BackgroundTasks
#endif

@Observable
final class NotificationManager {

    static let shared = NotificationManager()

    var isEnabled: Bool = false {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled") }
    }

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    self.isEnabled = false
                }
                completion(granted)
            }
        }
    }

    // MARK: - Background Refresh

#if os(iOS)
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.skyrift.weather-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.skyrift.weather-refresh")
    }

    func handleBackgroundRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            guard let location = loadCurrentLocation() else {
                task.setTaskCompleted(success: false)
                scheduleBackgroundRefresh()
                return
            }

            do {
                let weather = try await WeatherService().fetchDetailedWeather(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                let currentCode = weather.current.weatherCode
                let prevCode = UserDefaults.standard.integer(forKey: "notif_prevWeatherCode")

                // Severe weather notification
                if severity(for: currentCode) >= 3 && severity(for: currentCode) > severity(for: prevCode) {
                    sendNotification(cityName: location.cityName, weatherCode: currentCode)
                }
                UserDefaults.standard.set(currentCode, forKey: "notif_prevWeatherCode")

                // UV reminder — once per day when UV ≥ 6 and daytime
                let uvEnabled = UserDefaults.standard.bool(forKey: "uvReminderEnabled")
                let todayStr = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
                let lastUVDate = UserDefaults.standard.string(forKey: "lastUVNotificationDate") ?? ""
                if uvEnabled && weather.current.isDay == 1 && weather.current.uvIndex >= 6 && todayStr != lastUVDate {
                    sendUVNotification(cityName: location.cityName)
                    UserDefaults.standard.set(todayStr, forKey: "lastUVNotificationDate")
                }

                // Rain starting soon check
                checkRainStartingSoon(cityName: location.cityName, hourly: weather.hourly)

                // Reschedule daily summary with fresh weather data
                scheduleDailySummaryIfEnabled(cityName: location.cityName, weather: weather)

                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }

            scheduleBackgroundRefresh()
        }
    }
#else
    func scheduleBackgroundRefresh() {}

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
#endif

    // MARK: - Severity

    func severity(for code: Int) -> Int {
        switch code {
        case 0...3:         return 0
        case 45, 48:        return 2
        case 51...55:       return 3
        case 56...67,
             71...77,
             80...86:       return 4
        case 95:            return 6
        case 96, 99:        return 7
        default:            return 0
        }
    }

    // MARK: - Send Notification

    func sendNotification(cityName: String, weatherCode: Int) {
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        content.sound = .default

        let sev = severity(for: weatherCode)
        switch sev {
        case 2:
            content.body = "notification_body_fog".localized(cityName)
        case 3:
            content.body = "notification_body_rain".localized(cityName)
        case 4:
            if (56...67).contains(weatherCode) || (80...82).contains(weatherCode) {
                content.body = "notification_body_heavy_rain".localized(cityName)
            } else if [71, 73, 75, 77, 85, 86].contains(weatherCode) {
                content.body = "notification_body_snow".localized(cityName)
            } else {
                content.body = "notification_body_freezing".localized(cityName)
            }
        case 6, 7:
            content.body = "notification_body_thunderstorm".localized(cityName)
        default:
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UV Notification

    func sendUVNotification(cityName: String) {
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        content.body = "notification_body_uv".localized(cityName)
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "skyrift-uv-\(Int(Date().timeIntervalSince1970))",
            content: content, trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Rain Starting Soon

    func checkRainStartingSoon(cityName: String, hourly: [HourlyForecast]) {
        guard UserDefaults.standard.bool(forKey: "rainStartingEnabled") else { return }

        let now = Date()

        // Already raining / high probability right now → skip
        let currentProb = hourly.first(where: { $0.time <= now })?.precipitationProbability ?? 0
        guard currentProb < 30 else { return }

        // Check if precipitation probability reaches ≥60% in the next 2 hours
        let upcoming = hourly.filter { $0.time > now && $0.time <= now.addingTimeInterval(2 * 3600) }
        guard upcoming.contains(where: { $0.precipitationProbability >= 60 }) else { return }

        // 4-hour cooldown to avoid spamming
        let cooldownKey = "lastRainStartingNotificationDate"
        if let lastDate = UserDefaults.standard.object(forKey: cooldownKey) as? Date,
           now.timeIntervalSince(lastDate) < 4 * 3600 { return }

        UserDefaults.standard.set(now, forKey: cooldownKey)
        sendRainStartingSoonNotification(cityName: cityName)
    }

    private func sendRainStartingSoonNotification(cityName: String) {
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        content.body = "notification_body_rain_starting".localized(cityName)
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "skyrift-rain-starting-\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily Summary

    func scheduleDailySummary(hour: Int, minute: Int, cityName: String, weather: WeatherData) {
        cancelDailySummary()
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        content.sound = .default
        let condition = WeatherCondition.from(
            code: weather.current.weatherCode,
            isDay: weather.current.isDay == 1
        )
        let maxTemp = weather.daily.first.map { Int($0.maxTemp.rounded()) } ?? Int(weather.current.temperature.rounded())
        let minTemp = weather.daily.first.map { Int($0.minTemp.rounded()) } ?? Int(weather.current.temperature.rounded())
        content.body = "daily_summary_body".localized(cityName, condition.description, maxTemp, minTemp)
        var dc = DateComponents()
        dc.hour = hour
        dc.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let request = UNNotificationRequest(identifier: "skyrift-daily-summary", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelDailySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["skyrift-daily-summary"])
    }

    func scheduleDailySummaryIfEnabled(cityName: String, weather: WeatherData) {
        guard UserDefaults.standard.bool(forKey: "dailySummaryEnabled") else { return }
        let h = UserDefaults.standard.object(forKey: "dailySummaryHour") != nil
            ? UserDefaults.standard.integer(forKey: "dailySummaryHour") : 7
        let m = UserDefaults.standard.object(forKey: "dailySummaryMinute") != nil
            ? UserDefaults.standard.integer(forKey: "dailySummaryMinute") : 30
        scheduleDailySummary(hour: h, minute: m, cityName: cityName, weather: weather)
    }

    // MARK: - Load Current Location

    private func loadCurrentLocation() -> WeatherLocation? {
        guard let data = UserDefaults.standard.data(forKey: "savedLocations"),
              let locations = try? JSONDecoder().decode([WeatherLocation].self, from: data) else {
            return nil
        }
        return locations.first(where: { $0.isCurrentLocation }) ?? locations.first
    }
}
