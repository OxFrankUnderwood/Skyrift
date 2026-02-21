//
//  WeatherService.swift
//  Skyrift
//

import Foundation

struct WeatherService {

    // MARK: - Fetch Weather

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,is_day&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max&timezone=auto&forecast_days=7"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenMeteoForecastResponse.self, from: data)
        return response.toWeatherData()
    }

    // MARK: - Search Locations

    func searchLocations(query: String) async throws -> [WeatherLocation] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=10&language=tr&format=json"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

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
}

// MARK: - Open-Meteo Decoding Types

private struct OpenMeteoForecastResponse: Decodable {
    let current: CurrentResponse
    let daily: DailyResponse

    struct CurrentResponse: Decodable {
        let temperature2m: Double
        let relativeHumidity2m: Int
        let apparentTemperature: Double
        let weatherCode: Int
        let windSpeed10m: Double
        let isDay: Int

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
            case isDay = "is_day"
        }
    }

    struct DailyResponse: Decodable {
        let time: [String]
        let weatherCode: [Int]
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]
        let precipitationSum: [Double]
        let windSpeed10mMax: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }

    func toWeatherData() -> WeatherData {
        let current = CurrentWeather(
            temperature: current.temperature2m,
            apparentTemperature: current.apparentTemperature,
            humidity: current.relativeHumidity2m,
            windSpeed: current.windSpeed10m,
            weatherCode: current.weatherCode,
            isDay: current.isDay
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let forecasts = zip(daily.time.indices, daily.time).compactMap { index, dateString -> DailyForecast? in
            guard let date = dateFormatter.date(from: dateString) else { return nil }
            return DailyForecast(
                date: date,
                maxTemp: daily.temperature2mMax[index],
                minTemp: daily.temperature2mMin[index],
                weatherCode: daily.weatherCode[index],
                precipitationSum: daily.precipitationSum[index],
                maxWindSpeed: daily.windSpeed10mMax[index]
            )
        }

        return WeatherData(current: current, daily: forecasts)
    }
}

private struct GeocodingResponse: Decodable {
    let results: [GeocodingResult]?
}

private struct GeocodingResult: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
}
