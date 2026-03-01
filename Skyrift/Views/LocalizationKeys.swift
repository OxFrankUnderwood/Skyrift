//
//  LocalizationKeys.swift
//  Skyrift
//
//  Localization key constants for type-safe localization
//

import Foundation

enum L10n {
    // MARK: - General
    static let appName = "app_name"
    static let close = "close"
    static let done = "done"
    static let cancel = "cancel"
    static let delete = "delete"
    static let retry = "retry"
    static let loading = "loading"
    
    // MARK: - Weather View
    static let navTitle = "nav_title"
    static let loadingWeather = "loading_weather"
    static let errorLoading = "error_loading"
    static let selectLocation = "select_location"
    static let useMyLocation = "use_my_location"
    static let retryLoading = "retry_loading"
    static let forecastLabel = "forecast_label"
    static let forecast3Days = "forecast_3_days"
    static let forecast7Days = "forecast_7_days"
    static let forecast10Days = "forecast_10_days"
    
    // MARK: - Current Weather
    static let feelsLike = "feels_like"
    static let humidity = "humidity"
    static let wind = "wind"
    
    // MARK: - Location Search
    static let locationsTitle = "locations_title"
    static let useCurrentLocation = "use_current_location"
    static let savedLocations = "saved_locations"
    static let searchResults = "search_results"
    static let searchResultsCount = "search_results_count"
    static let popularCities = "popular_cities"
    static let searchCity = "search_city"
    static let searchPlaceholder = "search_placeholder"
    static let searchInstruction = "search_instruction"
    static let noResults = "no_results"
    static let searchFailed = "search_failed"
    
    // MARK: - Daily Detail
    static let hourlyForecast = "hourly_forecast"
    static let totalPrecipitation = "total_precipitation"
    static let maxWind = "max_wind"
    static let precipitation = "precipitation"
    static let noHourlyData = "no_hourly_data"
}
