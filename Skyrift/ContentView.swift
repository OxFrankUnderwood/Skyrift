//
//  ContentView.swift
//  Skyrift
//

import CoreLocation
import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var languageObserver: NSObjectProtocol?
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    
    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }
    
    init() {
        setupAppearance()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WeatherView(viewModel: viewModel, locationManager: locationManager)
                .tabItem {
                    Label(L10n.weatherTab.localized, systemImage: "cloud.sun.fill")
                }
                .tag(0)
            
            NavigationStack {
                LocationSearchView(viewModel: viewModel, locationManager: locationManager)
            }
            .tabItem {
                Label(L10n.locationsTab.localized, systemImage: "location.fill")
            }
            .tag(1)

            InsightsView(viewModel: viewModel)
                .tabItem {
                    Label("insights_tab".localized, systemImage: "sparkles")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(L10n.settingsTab.localized, systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .preferredColorScheme(appearanceMode.colorScheme)
        .onAppear {
            // UI render edildikten SONRA veri yükle
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                if let firstSaved = viewModel.savedLocations.first {
                    if firstSaved.isCurrentLocation {
                        locationManager.requestLocation()
                        // Önceki oturumdan koordinat zaten varsa hemen yükle
                        if locationManager.coordinate != nil {
                            await viewModel.selectCurrentLocation(locationManager: locationManager)
                        }
                        // Yoksa onChange(of: locationManager.coordinate != nil) bekleyecek
                    } else {
                        await viewModel.loadWeather(for: firstSaved)
                    }
                }
            }
            
            // Dil değişikliğini dinle
            languageObserver = NotificationCenter.default.addObserver(
                forName: .languageChanged,
                object: nil,
                queue: .main
            ) { _ in
                // Dil değiştiğinde mevcut konumu yeniden yükle
                Task { @MainActor in
                    if let currentLocation = viewModel.selectedLocation {
                        await viewModel.reloadWeather(for: currentLocation)
                    }
                }
            }
        }
        .onDisappear {
            // Observer'ı temizle
            if let observer = languageObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        .onChange(of: locationManager.coordinate != nil) { oldHad, nowHas in
            // GPS koordinatı ilk kez geldiğinde yükle
            guard !oldHad && nowHas else { return }
            guard let coord = locationManager.coordinate else { return }
            // Mevcut konum kaydedilmişse ve henüz hava verisi yoksa yükle
            if let first = viewModel.savedLocations.first, first.isCurrentLocation, viewModel.weatherData == nil {
                // Koordinatları güncelle (önceden placeholder olabilir)
                viewModel.addCurrentLocationPlaceholder(
                    name: locationManager.cityName.isEmpty ? L10n.currentLocation.localized : locationManager.cityName,
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
                Task {
                    await viewModel.selectCurrentLocation(locationManager: locationManager)
                }
            }
            // Placeholder henüz eklenmemişse LocationSearchView.onChange(cityName) devralır.
        }
    }
    
    private func setupAppearance() {
        if #available(iOS 26, *) {
            // iOS 26: Şeffaf arka plan — sistem floating glass tab bar sağlıyor
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else {
            // iOS 18: Blur material arka plan
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }
}

#Preview {
    ContentView()
}
