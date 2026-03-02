//
//  ContentView.swift
//  Skyrift
//

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
                Task {
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
            // GPS koordinatı ilk kez geldiğinde yükle (önceki oturumdan koordinat yoksa)
            guard !oldHad && nowHas else { return }
            if viewModel.savedLocations.first?.isCurrentLocation == true && viewModel.weatherData == nil {
                Task {
                    await viewModel.selectCurrentLocation(locationManager: locationManager)
                }
            }
        }
    }
    
    private func setupAppearance() {
        // TabBar şeffaf - optimize edilmiş
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // NavigationBar şeffaf - optimize edilmiş
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }
}

#Preview {
    ContentView()
}
