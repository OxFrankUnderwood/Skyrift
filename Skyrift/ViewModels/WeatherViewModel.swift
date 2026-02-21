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

    init() {
        loadPersistedLocations()
    }

    // MARK: - Weather Loading

    func loadWeather(for location: WeatherLocation) async {
        isLoading = true
        errorMessage = nil
        selectedLocation = location

        do {
            weatherData = try await service.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } catch {
            errorMessage = "Hava durumu yüklenemedi: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refresh() async {
        guard let location = selectedLocation else { return }
        await loadWeather(for: location)
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
