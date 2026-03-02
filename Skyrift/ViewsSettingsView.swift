//
//  SettingsView.swift
//  Skyrift
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("enableAnimations") private var enableAnimations = true
    @AppStorage("liveActivityEnabled") private var liveActivityEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("temperatureUnit") private var temperatureUnitRaw = TemperatureUnit.celsius.rawValue
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue
    @AppStorage("widgetLocationId") private var widgetLocationId = ""
    @State private var languageManager = LanguageManager.shared
    @State private var settingsLocations: [WeatherLocation] = []
    
    var body: some View {
        NavigationStack {
            List {
                // Dil - En üstte
                Section {
                    Picker(selection: $languageManager.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    } label: {
                        Label {
                            Text(L10n.language.localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                // Birimler
                Section(L10n.units.localized) {
                    Picker(selection: $temperatureUnitRaw) {
                        ForEach(TemperatureUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.displayName).tag(unit.rawValue)
                        }
                    } label: {
                        Label {
                            Text(L10n.temperatureUnit.localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "thermometer.medium")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                // Canlı Aktiviteler & Bildirimler
                Section {
                    #if os(iOS)
                    Toggle(isOn: $notificationsEnabled) {
                        Label {
                            Text(L10n.notificationsWeatherAlerts.localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.requestPermission { granted in
                                if granted {
                                    NotificationManager.shared.scheduleBackgroundRefresh()
                                } else {
                                    notificationsEnabled = false
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelAll()
                        }
                    }
                    #endif

                    Toggle(isOn: $liveActivityEnabled) {
                        Label {
                            Text("Live Activity")
                                .font(.body)
                        } icon: {
                            Image(systemName: "apps.iphone")
                                .foregroundStyle(.pink)
                        }
                    }
                    .onChange(of: liveActivityEnabled) { _, newValue in
                        Task { @MainActor in
                            LiveActivityManager.shared.isEnabled = newValue

                            // Açıldıysa ve hava durumu varsa başlat
                            if newValue {
                                // WeatherViewModel'dan veri al ve başlat
                                // Bu kısım WeatherView'dan tetiklenecek
                            } else {
                                LiveActivityManager.shared.endActivity()
                            }
                        }
                    }

                    Picker(selection: $widgetLocationId) {
                        Text(L10n.widgetLocationAuto.localized).tag("")
                        ForEach(settingsLocations.filter { !$0.isCurrentLocation }) { loc in
                            Text(loc.name).tag(loc.id)
                        }
                    } label: {
                        Label {
                            Text(L10n.widgetLocation.localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "location.square.fill")
                                .foregroundStyle(.teal)
                        }
                    }
                } header: {
                    Text("notifications_section".localized)
                } footer: {
                    Text("live_activity_footer".localized)
                        .font(.caption)
                }
                
                // Görünüm
                Section(L10n.appearance.localized) {
                    Picker(selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    } label: {
                        Label {
                            Text("theme".localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(.indigo)
                        }
                    }
                    
                    Toggle(isOn: $enableAnimations) {
                        Label {
                            Text(L10n.animatedBackgrounds.localized)
                                .font(.body)
                        } icon: {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .foregroundStyle(.purple)
                        }
                    }
                }
                
                // Hakkında
                Section(L10n.about.localized) {
                    HStack {
                        Text(L10n.version.localized)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.tertiary)
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle(L10n.settings.localized)
            .onAppear {
                if let data = UserDefaults.standard.data(forKey: "savedLocations"),
                   let locs = try? JSONDecoder().decode([WeatherLocation].self, from: data) {
                    settingsLocations = locs
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
