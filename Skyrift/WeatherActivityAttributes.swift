//
//  WeatherActivityAttributes.swift
//  Skyrift
//
//  Shared Activity Attributes for Live Activity
//

import ActivityKit
import Foundation

// MARK: - Activity Attributes

struct WeatherActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var temperature: Double
        var weatherCode: Int
        var isDay: Bool
        var cityName: String
        var lastUpdate: Date
    }
    
    // Sabit özellikler (değişmez)
    var locationId: String
}
