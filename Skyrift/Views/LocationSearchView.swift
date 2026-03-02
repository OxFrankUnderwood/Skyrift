//
//  LocationSearchView.swift
//  Skyrift
//

import CoreLocation
import SwiftUI

struct LocationSearchView: View {
    var viewModel: WeatherViewModel
    var locationManager: LocationManager

    @AppStorage("showCurrentLocation") private var showCurrentLocation = true

    @State private var searchText = ""
    @State private var searchResults: [WeatherLocation] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var searchTask: Task<Void, Never>?

    private let service = WeatherService()
    
    // Popüler şehirler - kullanıcının ülkesine göre dinamik
    private var popularCities: [WeatherLocation] {
        // Kullanıcının ülkesini tespit et
        let userCountry = detectUserCountry()
        
        // Ülkeye göre popüler şehirler
        let allPopular = getPopularCities(for: userCountry)
        
        // Zaten kaydedilmiş olanları filtrele
        return allPopular.filter { popular in
            !viewModel.savedLocations.contains { saved in
                saved.name == popular.name
            }
        }
    }
    
    private var defaultCountry: String {
        let regionCode = Locale.current.region?.identifier ?? "US"
        return Locale.current.localizedString(forRegionCode: regionCode) ?? "United States"
    }

    // Kullanıcının ülkesini tespit et
    private func detectUserCountry() -> String {
        // 1. LocationManager'dan mevcut konum varsa
        let cityName = locationManager.cityName
        if !cityName.isEmpty {
            // "İstanbul, Türkiye" -> "Türkiye"
            let components = cityName.split(separator: ",")
            if components.count > 1 {
                return String(components.last?.trimmingCharacters(in: .whitespaces) ?? defaultCountry)
            }
        }

        // 2. Kayıtlı konumlardan ilki
        if let firstLocation = viewModel.savedLocations.first {
            let components = firstLocation.name.split(separator: ",")
            if components.count > 1 {
                return String(components.last?.trimmingCharacters(in: .whitespaces) ?? defaultCountry)
            }
        }

        // 3. Locale'den tahmin et
        return defaultCountry
    }
    
    // Ülke kodundan ülke adı
    private func countryName(from code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? defaultCountry
    }
    
    // Ülkeye göre popüler şehirler
    private func getPopularCities(for country: String) -> [WeatherLocation] {
        switch country.lowercased() {
        case let c where c.contains("türkiye") || c.contains("turkey"):
            return [
                WeatherLocation(name: "İstanbul, Türkiye", latitude: 41.0082, longitude: 28.9784),
                WeatherLocation(name: "Ankara, Türkiye", latitude: 39.9334, longitude: 32.8597),
                WeatherLocation(name: "İzmir, Türkiye", latitude: 38.4237, longitude: 27.1428),
                WeatherLocation(name: "Antalya, Türkiye", latitude: 36.8969, longitude: 30.7133),
                WeatherLocation(name: "Bursa, Türkiye", latitude: 40.1826, longitude: 29.0665),
            ]
            
        case let c where c.contains("united states") || c.contains("america") || c.contains("abd"):
            return [
                WeatherLocation(name: "New York, United States", latitude: 40.7128, longitude: -74.0060),
                WeatherLocation(name: "Los Angeles, United States", latitude: 34.0522, longitude: -118.2437),
                WeatherLocation(name: "Chicago, United States", latitude: 41.8781, longitude: -87.6298),
                WeatherLocation(name: "Miami, United States", latitude: 25.7617, longitude: -80.1918),
                WeatherLocation(name: "San Francisco, United States", latitude: 37.7749, longitude: -122.4194),
            ]
            
        case let c where c.contains("united kingdom") || c.contains("england") || c.contains("ingiltere"):
            return [
                WeatherLocation(name: "London, United Kingdom", latitude: 51.5074, longitude: -0.1278),
                WeatherLocation(name: "Manchester, United Kingdom", latitude: 53.4808, longitude: -2.2426),
                WeatherLocation(name: "Birmingham, United Kingdom", latitude: 52.4862, longitude: -1.8904),
                WeatherLocation(name: "Edinburgh, United Kingdom", latitude: 55.9533, longitude: -3.1883),
                WeatherLocation(name: "Liverpool, United Kingdom", latitude: 53.4084, longitude: -2.9916),
            ]
            
        case let c where c.contains("germany") || c.contains("almanya") || c.contains("deutschland"):
            return [
                WeatherLocation(name: "Berlin, Germany", latitude: 52.5200, longitude: 13.4050),
                WeatherLocation(name: "Munich, Germany", latitude: 48.1351, longitude: 11.5820),
                WeatherLocation(name: "Frankfurt, Germany", latitude: 50.1109, longitude: 8.6821),
                WeatherLocation(name: "Hamburg, Germany", latitude: 53.5511, longitude: 9.9937),
                WeatherLocation(name: "Cologne, Germany", latitude: 50.9375, longitude: 6.9603),
            ]
            
        case let c where c.contains("france") || c.contains("fransa"):
            return [
                WeatherLocation(name: "Paris, France", latitude: 48.8566, longitude: 2.3522),
                WeatherLocation(name: "Marseille, France", latitude: 43.2965, longitude: 5.3698),
                WeatherLocation(name: "Lyon, France", latitude: 45.7640, longitude: 4.8357),
                WeatherLocation(name: "Nice, France", latitude: 43.7102, longitude: 7.2620),
                WeatherLocation(name: "Toulouse, France", latitude: 43.6047, longitude: 1.4442),
            ]
            
        case let c where c.contains("spain") || c.contains("ispanya") || c.contains("españa"):
            return [
                WeatherLocation(name: "Madrid, Spain", latitude: 40.4168, longitude: -3.7038),
                WeatherLocation(name: "Barcelona, Spain", latitude: 41.3851, longitude: 2.1734),
                WeatherLocation(name: "Valencia, Spain", latitude: 39.4699, longitude: -0.3763),
                WeatherLocation(name: "Seville, Spain", latitude: 37.3891, longitude: -5.9845),
                WeatherLocation(name: "Malaga, Spain", latitude: 36.7213, longitude: -4.4214),
            ]
            
        case let c where c.contains("italy") || c.contains("italya") || c.contains("italia"):
            return [
                WeatherLocation(name: "Rome, Italy", latitude: 41.9028, longitude: 12.4964),
                WeatherLocation(name: "Milan, Italy", latitude: 45.4642, longitude: 9.1900),
                WeatherLocation(name: "Venice, Italy", latitude: 45.4408, longitude: 12.3155),
                WeatherLocation(name: "Florence, Italy", latitude: 43.7696, longitude: 11.2558),
                WeatherLocation(name: "Naples, Italy", latitude: 40.8518, longitude: 14.2681),
            ]
            
        default:
            // Dünya çapında popüler şehirler
            return [
                WeatherLocation(name: "London, United Kingdom", latitude: 51.5074, longitude: -0.1278),
                WeatherLocation(name: "Paris, France", latitude: 48.8566, longitude: 2.3522),
                WeatherLocation(name: "New York, United States", latitude: 40.7128, longitude: -74.0060),
                WeatherLocation(name: "Tokyo, Japan", latitude: 35.6762, longitude: 139.6503),
                WeatherLocation(name: "Dubai, United Arab Emirates", latitude: 25.2048, longitude: 55.2708),
            ]
        }
    }

    var body: some View {
        NavigationStack {
            listContent
                .navigationTitle(L10n.locationsTitle.localized)
                .navigationBarTitleDisplayMode(.large)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: L10n.searchPlaceholder.localized
                )
                .onAppear {
                    // Koordinat güncellendikçe placeholder'ı senkronize et
                    if showCurrentLocation, let coord = locationManager.coordinate {
                        viewModel.addCurrentLocationPlaceholder(
                            name: locationManager.cityName,
                            latitude: coord.latitude,
                            longitude: coord.longitude
                        )
                    }
                }
                .onChange(of: locationManager.cityName) { _, name in
                    guard showCurrentLocation, let coord = locationManager.coordinate else { return }
                    viewModel.addCurrentLocationPlaceholder(
                        name: name,
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                }
                .onChange(of: searchText) { _, newValue in
                    searchTask?.cancel()
                    if newValue.isEmpty {
                        searchResults = []
                        searchError = nil
                        return
                    }
                    searchTask = Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        guard !Task.isCancelled else { return }
                        performSearch()
                    }
                }
        }
    }
    
    private var listContent: some View {
        List {
            // Mevcut konum toggle
            Section {
                HStack {
                    Label(L10n.useCurrentLocation.localized, systemImage: "location.fill")
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $showCurrentLocation)
                        .labelsHidden()
                }
            }
            .onChange(of: showCurrentLocation) { _, enabled in
                if enabled {
                    locationManager.requestLocation()
                    if let coord = locationManager.coordinate {
                        viewModel.addCurrentLocationPlaceholder(
                            name: locationManager.cityName,
                            latitude: coord.latitude,
                            longitude: coord.longitude
                        )
                    }
                } else {
                    viewModel.removeCurrentLocationPlaceholder()
                }
            }

            // Kayıtlı konumlar (mevcut konum placeholder dahil, sıralanabilir)
            if !viewModel.savedLocations.isEmpty {
                Section(L10n.savedLocations.localized) {
                    ForEach(viewModel.savedLocations) { location in
                        HStack {
                            if location.isCurrentLocation {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                            }
                            Button {
                                Task {
                                    if location.isCurrentLocation {
                                        await viewModel.selectCurrentLocation(locationManager: locationManager)
                                    } else {
                                        await viewModel.loadWeather(for: location)
                                    }
                                }
                            } label: {
                                Text(location.cityName)
                                    .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                    }
                    .onMove { source, destination in
                        viewModel.moveLocation(from: source, to: destination)
                    }
                    .onDelete { offsets in
                        // Mevcut konum placeholder silinirse toggle'ı da kapat
                        for index in offsets {
                            if viewModel.savedLocations[index].isCurrentLocation {
                                showCurrentLocation = false
                            }
                        }
                        viewModel.removeLocation(at: offsets)
                    }
                }
                .environment(\.editMode, .constant(.active))
            }

            // Search results
            if !searchResults.isEmpty {
                Section(L10n.searchResults.localized + " (\(searchResults.count))") {
                    ForEach(searchResults) { location in
                        Button {
                            viewModel.addLocation(location)
                            Task {
                                await viewModel.loadWeather(for: location)
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            } else if !searchText.isEmpty {
                // Arama yapıldı ama sonuç yok
                Section {
                    if isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else {
                        Text(L10n.noResults.localized)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            
            // Popüler şehirleri her zaman göster (arama yapılmamışsa)
            if searchText.isEmpty {
                Section(L10n.popularCities.localized) {
                    ForEach(popularCities) { location in
                        Button {
                            viewModel.addLocation(location)
                            Task {
                                await viewModel.loadWeather(for: location)
                            }
                        } label: {
                            HStack {
                                Text(location.cityName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                // Eğer bu konum zaten kayıtlıysa, farklı ikon göster
                                if viewModel.savedLocations.contains(where: { $0.id == location.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .disabled(viewModel.savedLocations.contains(where: { $0.id == location.id }))
                    }
                }
            }

            if let error = searchError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        #if DEBUG
        print("🔍 Arama yapılıyor: \(searchText)")
        #endif
        isSearching = true
        searchError = nil

        Task { @MainActor in
            do {
                let results = try await service.searchLocations(query: searchText)
                #if DEBUG
                print("✅ Arama sonuçları geldi: \(results.count) sonuç")
                #endif
                searchResults = results
                if searchResults.isEmpty {
                    searchError = "search_no_results".localized
                }
            } catch {
                #if DEBUG
                print("❌ Arama hatası: \(error.localizedDescription)")
                #endif
                searchError = "search_failed".localized(error.localizedDescription)
            }
            isSearching = false
        }
    }
}
