//
//  SkyriftApp.swift
//  Skyrift
//
//  Created by Emre on 22.02.2026.
//

import SwiftUI

#if os(iOS)
import BackgroundTasks
#endif

@main
struct SkyriftApp: App {
    @State private var languageManager = LanguageManager.shared
    @State private var showSplash = true
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    init() {
        #if os(iOS)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.skyrift.weather-refresh",
            using: nil
        ) { task in
            NotificationManager.shared.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
        #endif

    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    // Splash Screen (Logo Ekranı)
                    SplashScreenView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(2) // En üstte görünsün
                        .onChange(of: showSplash) { oldValue, newValue in
                            print("🎬 Splash Screen: \(newValue)")
                        }
                } else if !hasCompletedOnboarding {
                    // Onboarding (İlk Açılış Ekranları)
                    OnboardingView(isOnboardingCompleted: $hasCompletedOnboarding)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                        .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
                            print("📱 Onboarding Tamamlandı: \(newValue)")
                        }
                } else {
                    // Ana Uygulama
                    ContentView()
                        .environment(\.locale, languageManager.currentLocale)
                        .id(languageManager.currentLanguage) // Dil değişince view'ı yenile
                        .transition(.opacity)
                        .zIndex(0)
                        .onAppear {
                            print("✅ Ana Uygulama Yüklendi")
                        }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
            .onAppear {
                print("🚀 App Başladı - Splash: \(showSplash), Onboarding: \(hasCompletedOnboarding)")
            }
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 390, height: 844)
#endif
    }
}
