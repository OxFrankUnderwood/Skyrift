//
//  LocalizationTest.swift
//  Skyrift
//
//  Lokalizasyon test helper
//

import Foundation

class LocalizationTest {
    static func testLocalization() {
        print("🌍 Lokalizasyon Testi")
        print("━━━━━━━━━━━━━━━━━━━")
        
        // Mevcut dil
        let currentLanguage = Locale.preferredLanguages.first ?? "unknown"
        print("📱 Sistem Dili: \(currentLanguage)")
        
        // Test stringleri
        let testKeys = [
            "weather_tab",
            "feels_like",
            "loading_weather",
            "settings"
        ]
        
        print("\n🧪 Test Sonuçları:")
        for key in testKeys {
            let localized = NSLocalizedString(key, comment: "")
            let status = localized == key ? "❌ BULUNAMADI" : "✅ BULUNDU"
            print("\(status) '\(key)' → '\(localized)'")
        }
        
        // Bundle kontrol
        print("\n📦 Bundle Kontrol:")
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings") {
            print("✅ Localizable.strings bulundu: \(path)")
        } else {
            print("❌ Localizable.strings BULUNAMADI!")
        }
        
        // Dil klasörleri kontrol
        print("\n📁 Dil Klasörleri:")
        let languages = ["tr", "en"]
        for lang in languages {
            if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: lang) {
                print("✅ \(lang): \(path)")
            } else {
                print("❌ \(lang): BULUNAMADI")
            }
        }
        
        print("━━━━━━━━━━━━━━━━━━━\n")
    }
}
