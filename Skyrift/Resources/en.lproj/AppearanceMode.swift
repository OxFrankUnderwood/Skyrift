//
//  AppearanceMode.swift
//  Skyrift
//
//  Appearance mode management (Light/Dark/System)
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "appearance_system".localized
        case .light:
            return "appearance_light".localized
        case .dark:
            return "appearance_dark".localized
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
