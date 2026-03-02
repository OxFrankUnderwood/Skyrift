//
//  TemperatureUnit.swift
//  Skyrift
//
//  Sıcaklık birimi yönetimi
//

import Foundation

enum TemperatureUnit: String, CaseIterable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    var displayName: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    func convert(_ celsius: Double) -> Double {
        switch self {
        case .celsius: return celsius
        case .fahrenheit: return celsius * 9/5 + 32
        }
    }
}

extension Double {
    func formatted(unit: TemperatureUnit) -> String {
        let converted = unit.convert(self)
        return String(format: "%.0f%@", converted, unit.symbol)
    }
}
