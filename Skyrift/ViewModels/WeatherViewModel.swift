//
//  WeatherViewModel.swift
//  Skyrift
//

import CoreLocation
import Foundation
import Observation
import SwiftUI

@Observable
final class WeatherViewModel {

    var savedLocations: [WeatherLocation] = [] {
        didSet { persistLocations() }
    }
    var selectedLocation: WeatherLocation?
    var weatherData: WeatherData?
    var isLoading = false
    var errorMessage: String?

    private let service = WeatherService()
    private let userDefaultsKey = "savedLocations"
    
    // Cache sistemi - konum ID'sine göre hava durumu verilerini saklayalım
    private var weatherCache: [String: WeatherData] = [:]

    init() {
        loadPersistedLocations()
    }

    // MARK: - Weather Loading

    func loadWeather(for location: WeatherLocation) async {
        // Cache kontrolü - önce bakıyoruz
        if let cachedWeather = weatherCache[location.id], !cachedWeather.hourly.isEmpty {
            print("💾 Cache'ten hızlı yükleme: \(location.name)")
            // Cache'ten hızlıca yükle - UI anında güncellenir
            await MainActor.run {
                selectedLocation = location
                weatherData = cachedWeather
                isLoading = false
            }
            return
        }
        
        print("🔄 API'den yükleniyor: \(location.name)")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            selectedLocation = location
        }

        do {
            // Detaylı yükleme - saatlik veri dahil
            let weather = try await service.fetchDetailedWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
            print("✅ Veri yüklendi - Günlük: \(weather.daily.count), Saatlik: \(weather.hourly.count)")
            
            await MainActor.run {
                weatherData = weather
                weatherCache[location.id] = weather // Cache'e kaydet
                isLoading = false
                
                // Widget'ı güncelle — sadece seçili widget konumu için
                let widgetLocationId = UserDefaults.standard.string(forKey: "widgetLocationId") ?? ""
                let isValidPref = !widgetLocationId.isEmpty && savedLocations.contains { $0.id == widgetLocationId }
                let shouldSaveWidget = !isValidPref || location.id == widgetLocationId

                if shouldSaveWidget, let firstDay = weather.daily.first {
                    // İleri 6 saat için saatlik tahmin
                    let now = Date()
                    let next6Hours = weather.hourly.filter { hourly in
                        hourly.time >= now && hourly.time <= now.addingTimeInterval(6 * 3600)
                    }.prefix(6)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    
                    let hourlyData: [[String: Any]] = next6Hours.map { hourly in
                        return [
                            "hour": formatter.string(from: hourly.time),
                            "temperature": hourly.temperature,
                            "weatherCode": hourly.weatherCode
                        ]
                    }
                    
                    WidgetDataManager.shared.saveWeatherForWidget(
                        temperature: weather.current.temperature,
                        apparentTemperature: weather.current.apparentTemperature,
                        weatherCode: weather.current.weatherCode,
                        isDay: weather.current.isDay,
                        cityName: location.cityName,
                        maxTemp: firstDay.maxTemp,
                        minTemp: firstDay.minTemp,
                        humidity: weather.current.humidity,
                        windSpeed: weather.current.windSpeed,
                        pressure: weather.current.pressure,
                        uvIndex: weather.current.uvIndex,
                        hourlyForecasts: hourlyData
                    )
                    
                    // Sabah özeti bildirimini yeni veriyle yenile
                    NotificationManager.shared.scheduleDailySummaryIfEnabled(
                        cityName: location.cityName,
                        weather: weather
                    )

                    // Live Activity güncelle/başlat
                    updateLiveActivity(weather: weather, location: location)
                }
            }
        } catch {
            print("❌ Yükleme hatası: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Hava durumu yüklenemedi: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // Detaylı veri yükleme (saatlik tahminler dahil) - artık gerek yok ama uyumluluk için bırakalım
    func loadDetailedWeather(for location: WeatherLocation) async {
        // Zaten loadWeather detaylı yüklüyor, ama yine de çağrılırsa güncelleyelim
        weatherCache.removeValue(forKey: location.id)
        await loadWeather(for: location)
    }

    func refresh() async {
        guard let location = selectedLocation else { return }
        // Cache'i temizle ve yeniden yükle
        weatherCache.removeValue(forKey: location.id)
        await loadWeather(for: location)
    }
    
    // Dil değiştiğinde cache'i temizleyip yeniden yükle
    func reloadWeather(for location: WeatherLocation) async {
        print("🌍 Dil değişti - Veri yeniden yükleniyor: \(location.name)")
        // Tüm cache'i temizle (çünkü API yanıtları dile göre değişiyor)
        weatherCache.removeAll()
        await loadWeather(for: location)
    }
    
    // MARK: - Live Activity
    
    private func updateLiveActivity(weather: WeatherData, location: WeatherLocation) {
        // Live Activity etkin mi kontrol et
        guard LiveActivityManager.shared.isEnabled else {
            return
        }
        
        Task { @MainActor in
            if LiveActivityManager.shared.isActivityActive {
                // Güncelle
                await LiveActivityManager.shared.updateActivity(
                    temperature: weather.current.temperature,
                    weatherCode: weather.current.weatherCode,
                    isDay: weather.current.isDay == 1,
                    cityName: location.cityName
                )
            } else {
                // Başlat
                LiveActivityManager.shared.startActivity(
                    temperature: weather.current.temperature,
                    weatherCode: weather.current.weatherCode,
                    isDay: weather.current.isDay == 1,
                    cityName: location.cityName,
                    locationId: location.id
                )
            }
        }
    }

    // MARK: - Location Management

    func selectCurrentLocation(locationManager: LocationManager) async {
        guard let coordinate = locationManager.coordinate else { return }
        let location = WeatherLocation(
            name: locationManager.cityName.isEmpty ? "Mevcut Konum" : locationManager.cityName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isCurrentLocation: true
        )
        await loadWeather(for: location)
    }

    // Mevcut konum placeholder'ını ekle/güncelle
    func addCurrentLocationPlaceholder(name: String, latitude: Double, longitude: Double) {
        let placeholder = WeatherLocation(
            name: name.isEmpty ? "Mevcut Konum" : name,
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: true
        )
        if let index = savedLocations.firstIndex(where: { $0.isCurrentLocation }) {
            savedLocations[index] = placeholder
        } else {
            savedLocations.insert(placeholder, at: 0)
        }
    }

    func removeCurrentLocationPlaceholder() {
        savedLocations.removeAll { $0.isCurrentLocation }
        if selectedLocation?.isCurrentLocation == true {
            selectedLocation = savedLocations.first
        }
    }

    func addLocation(_ location: WeatherLocation) {
        guard !savedLocations.contains(location) else { return }
        savedLocations.append(location)
    }

    func removeLocation(at offsets: IndexSet) {
        savedLocations.remove(atOffsets: offsets)
        if let selected = selectedLocation,
           !savedLocations.contains(where: { $0.id == selected.id }) && !selected.isCurrentLocation {
            selectedLocation = savedLocations.first
        }
    }
    
    func moveLocation(from source: IndexSet, to destination: Int) {
        savedLocations.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Persistence

    private func persistLocations() {
        if let data = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadPersistedLocations() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let locations = try? JSONDecoder().decode([WeatherLocation].self, from: data) else { return }
        savedLocations = locations
    }
}
