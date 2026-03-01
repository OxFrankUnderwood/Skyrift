//
//  WeatherService.swift
//  Skyrift
//
//  Uses Apple WeatherKit for weather data,
//  Open-Meteo geocoding API for location search (free, no key required).
//

import CoreLocation
import Foundation
import WeatherKit

// Resolve naming conflict: our struct is also called WeatherService
private typealias WKService = WeatherKit.WeatherService

struct WeatherService {

    // MARK: - Fetch Weather

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        let (current, daily, hourly) = try await WKService.shared.weather(
            for: location,
            including: .current,
            .daily,
            .hourly
        )

        return buildWeatherData(current: current, daily: daily, hourly: hourly)
    }

    func fetchDetailedWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        return try await fetchWeather(latitude: latitude, longitude: longitude)
    }

    // MARK: - Search Locations (Open-Meteo Geocoding)

    func searchLocations(query: String) async throws -> [WeatherLocation] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let languageCode = LanguageManager.shared.currentLanguage.code
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=10&language=\(languageCode)&format=json"

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)

        return (response.results ?? []).map { result in
            WeatherLocation(
                name: [result.name, result.country].compactMap { $0 }.joined(separator: ", "),
                latitude: result.latitude,
                longitude: result.longitude
            )
        }
    }

    // MARK: - Build WeatherData

    private func buildWeatherData(
        current: WeatherKit.CurrentWeather,
        daily: Forecast<DayWeather>,
        hourly: Forecast<HourWeather>
    ) -> WeatherData {
        let currentWeather = buildCurrentWeather(current)

        let dailyForecasts = Array(daily.prefix(7).map { buildDailyForecast($0) })

        let now = Date()
        let hourlyForecasts = Array(
            hourly
                .filter { $0.date >= now }
                .prefix(48)
                .map { buildHourlyForecast($0) }
        )

        return WeatherData(
            current: currentWeather,
            daily: dailyForecasts,
            hourly: hourlyForecasts,
            airQuality: nil
        )
    }

    private func buildCurrentWeather(_ wk: WeatherKit.CurrentWeather) -> CurrentWeather {
        CurrentWeather(
            temperature: wk.temperature.converted(to: .celsius).value,
            apparentTemperature: wk.apparentTemperature.converted(to: .celsius).value,
            humidity: Int((wk.humidity * 100).rounded()),
            windSpeed: wk.wind.speed.converted(to: .metersPerSecond).value,
            weatherCode: mapCondition(wk.condition),
            isDay: wk.isDaylight ? 1 : 0,
            uvIndex: Double(wk.uvIndex.value),
            visibility: wk.visibility.converted(to: .kilometers).value,
            pressure: wk.pressure.converted(to: .millibars).value,
            cloudCover: Int((wk.cloudCover * 100).rounded()),
            conditionText: nil
        )
    }

    private func buildDailyForecast(_ day: DayWeather) -> DailyForecast {
        DailyForecast(
            date: day.date,
            maxTemp: day.highTemperature.converted(to: .celsius).value,
            minTemp: day.lowTemperature.converted(to: .celsius).value,
            weatherCode: mapCondition(day.condition),
            precipitationSum: day.precipitationAmount.converted(to: .millimeters).value,
            maxWindSpeed: day.wind.speed.converted(to: .metersPerSecond).value,
            uvIndexMax: Double(day.uvIndex.value),
            precipitationProbability: Int((day.precipitationChance * 100).rounded()),
            sunrise: day.sun.sunrise ?? day.date,
            sunset: day.sun.sunset ?? day.date.addingTimeInterval(12 * 3600)
        )
    }

    private func buildHourlyForecast(_ hour: HourWeather) -> HourlyForecast {
        HourlyForecast(
            time: hour.date,
            temperature: hour.temperature.converted(to: .celsius).value,
            weatherCode: mapCondition(hour.condition),
            precipitationProbability: Int((hour.precipitationChance * 100).rounded()),
            precipitation: hour.precipitationAmount.converted(to: .millimeters).value,
            windSpeed: hour.wind.speed.converted(to: .metersPerSecond).value,
            humidity: Int((hour.humidity * 100).rounded())
        )
    }

    // MARK: - WeatherKit Condition → WMO Code Mapping

    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> Int {
        switch condition {
        case .clear:                                        return 0
        case .mostlyClear:                                  return 1
        case .partlyCloudy:                                 return 2
        case .mostlyCloudy, .cloudy:                        return 3
        case .foggy, .haze, .smoky:                         return 45
        case .drizzle:                                      return 51
        case .freezingDrizzle:                              return 56
        case .rain:                                         return 61
        case .heavyRain:                                    return 65
        case .freezingRain:                                 return 66
        case .wintryMix, .sleet:                            return 67
        case .flurries:                                     return 77
        case .snow:                                         return 71
        case .heavySnow, .blizzard, .blowingSnow:           return 75
        case .hail:                                         return 96
        case .thunderstorms, .scatteredThunderstorms:       return 95
        case .strongStorms, .tropicalStorm, .hurricane:     return 99
        case .breezy, .windy, .hot, .frigid, .blowingDust:  return 3
        @unknown default:                                   return 3
        }
    }
}

// MARK: - Geocoding Types

private struct GeocodingResponse: Decodable {
    let results: [GeocodingResult]?
}

private struct GeocodingResult: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
