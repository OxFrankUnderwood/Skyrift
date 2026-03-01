//
//  LanguageManager.swift
//  Skyrift
//
//  Manages app language and localization
//

import Foundation
import SwiftUI

@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
            updateAppLanguage()
        }
    }
    
    private init() {
        // Load saved language or use system default
        if let savedCode = UserDefaults.standard.string(forKey: "AppLanguage"),
           let savedLanguage = AppLanguage(rawValue: savedCode) {
            self.currentLanguage = savedLanguage
        } else {
            self.currentLanguage = .system
        }
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
    }
    
    private func updateAppLanguage() {
        // Update the app's language
        if currentLanguage == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([currentLanguage.code], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
}

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    case japanese = "ja"
    case korean = "ko"
    case chinese = "zh"
    case arabic = "ar"
    
    var id: String { rawValue }
    
    var code: String {
        switch self {
        case .system:
            return Locale.preferredLanguages.first ?? "en"
        default:
            return rawValue
        }
    }
    
    var displayName: String {
        switch self {
        case .system:
            return "system_default".localized
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
        case .portuguese:
            return "Português"
        case .russian:
            return "Русский"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .chinese:
            return "中文"
        case .arabic:
            return "العربية"
        }
    }
    
    var flag: String {
        switch self {
        case .system:
            return "🌍"
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
        case .portuguese:
            return "🇵🇹"
        case .russian:
            return "🇷🇺"
        case .japanese:
            return "🇯🇵"
        case .korean:
            return "🇰🇷"
        case .chinese:
            return "🇨🇳"
        case .arabic:
            return "🇸🇦"
        }
    }
}
