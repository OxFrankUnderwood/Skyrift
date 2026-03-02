//
//  LanguageManager.swift
//  Skyrift
//
//  Manages app language and localization
//

import Foundation
import SwiftUI
import WidgetKit

@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    var currentLanguage: AppLanguage {
        didSet {
            if oldValue != currentLanguage {
                saveLanguage()
                updateAppLanguage()
                // Anında yenile
                NotificationCenter.default.post(name: .languageChanged, object: nil)
            }
        }
    }
    
    var currentLocale: Locale {
        return Locale(identifier: currentLanguage.code)
    }
    
    // Bundle override için
    var currentBundle: Bundle {
        if let path = Bundle.main.path(forResource: currentLanguage.code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        
        return Bundle.main
    }
    
    private init() {
        // Load saved language or use English as default
        if let savedCode = UserDefaults.standard.string(forKey: "AppLanguage"),
           let savedLanguage = AppLanguage(rawValue: savedCode) {
            self.currentLanguage = savedLanguage
        } else {
            self.currentLanguage = .english // Default: English
        }
        
        // Widget için App Group'a da kaydet
        if let sharedDefaults = UserDefaults(suiteName: "group.com.skyrift.weather") {
            sharedDefaults.set(currentLanguage.code, forKey: "selectedLanguage")
            sharedDefaults.synchronize()
        }
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        
        // Widget için App Group'a kaydet
        if let sharedDefaults = UserDefaults(suiteName: "group.com.skyrift.weather") {
            sharedDefaults.set(currentLanguage.code, forKey: "selectedLanguage")
            sharedDefaults.synchronize()
            
            // Widget'ları reload et
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func updateAppLanguage() {
        // Locale'i güncelle
        UserDefaults.standard.set([currentLanguage.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

// Notification extension
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case russian = "ru"
    
    var id: String { rawValue }
    
    var code: String {
        return rawValue
    }
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .turkish:
            return "Türkçe"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .italian:
            return "Italiano"
        case .russian:
            return "Русский"
        }
    }
    
    var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .turkish:
            return "🇹🇷"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        case .german:
            return "🇩🇪"
        case .italian:
            return "🇮🇹"
        case .russian:
            return "🇷🇺"
        }
    }
}
