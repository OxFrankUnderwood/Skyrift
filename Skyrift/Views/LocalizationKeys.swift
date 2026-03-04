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
    
    // MARK: - Tabs
    static let weatherTab = "weather_tab"
    static let locationsTab = "locations_tab"
    static let settingsTab = "settings_tab"
    
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
    
    // MARK: - Location Search
    static let locationsTitle = "locations_title"
    static let useCurrentLocation = "use_current_location"
    static let currentLocation = "current_location"
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
    
    // MARK: - Settings
    static let settings = "settings"
    static let units = "units"
    static let temperatureUnit = "temperature_unit"
    static let temperatureUnitDesc = "temperature_unit_desc"
    static let appearance = "appearance"
    static let animatedBackgrounds = "animated_backgrounds"
    static let animatedBackgroundsDesc = "animated_backgrounds_desc"
    static let theme = "theme"
    static let appearanceSystem = "appearance_system"
    static let appearanceLight = "appearance_light"
    static let appearanceDark = "appearance_dark"
    static let language = "language"
    static let languageDesc = "language_desc"
    static let selectLanguage = "select_language"
    static let systemDefault = "system_default"
    static let about = "about"
    static let version = "version"
    static let appVersion = "app_version"
    static let languageChangeInstant = "language_change_instant"
    
    // MARK: - Weather Info
    static let feelsLike = "feels_like"
    static let humidity = "humidity"
    static let wind = "wind"
    static let uvIndex = "uv_index"
    static let visibility = "visibility"
    static let pressure = "pressure"
    static let cloudiness = "cloudiness"
    static let airQuality = "air_quality"
    
    // MARK: - Categories
    static let uvLow = "uv_low"
    static let uvModerate = "uv_moderate"
    static let uvHigh = "uv_high"
    static let uvVeryHigh = "uv_very_high"
    static let uvExtreme = "uv_extreme"
    
    static let visibilityVeryPoor = "visibility_very_poor"
    static let visibilityPoor = "visibility_poor"
    static let visibilityModerate = "visibility_moderate"
    static let visibilityGood = "visibility_good"
    
    static let pressureLow = "pressure_low"
    static let pressureNormal = "pressure_normal"
    static let pressureHigh = "pressure_high"
    
    static let cloudsFew = "clouds_few"
    static let cloudsScattered = "clouds_scattered"
    static let cloudsBroken = "clouds_broken"
    static let cloudsOvercast = "clouds_overcast"
    
    // MARK: - Air Quality Categories
    static let airQualityGood = "air_quality_good"
    static let airQualityModerate = "air_quality_moderate"
    static let airQualityPoor = "air_quality_poor"
    static let airQualityVeryPoor = "air_quality_very_poor"
    static let airQualityUnknown = "air_quality_unknown"
    
    // MARK: - Weather Conditions
    static let weatherClear = "weather_clear"
    static let weatherMostlyClear = "weather_mostly_clear"
    static let weatherPartlyCloudy = "weather_partly_cloudy"
    static let weatherOvercast = "weather_overcast"
    static let weatherFoggy = "weather_foggy"
    static let weatherDrizzle = "weather_drizzle"
    static let weatherFreezingDrizzle = "weather_freezing_drizzle"
    static let weatherRainy = "weather_rainy"
    static let weatherFreezingRain = "weather_freezing_rain"
    static let weatherSnowy = "weather_snowy"
    static let weatherSnowGrains = "weather_snow_grains"
    static let weatherRainShowers = "weather_rain_showers"
    static let weatherSnowShowers = "weather_snow_showers"
    static let weatherThunderstorm = "weather_thunderstorm"
    static let weatherThunderstormHail = "weather_thunderstorm_hail"
    static let weatherCloudy = "weather_cloudy"
    
    // MARK: - Daily Detail
    static let loadingHourly = "loading_hourly"
    static let noHourlyData = "no_hourly_data"
    static let temperatureChange = "temperature_change"
    static let precipitationProbability = "precipitation_probability"
    static let windSpeed = "wind_speed"
    static let humidityLevel = "humidity_level"
    static let hourlyDetail = "hourly_detail"
    static let hour = "hour"
    static let temperature = "temperature"
    static let precipitation = "precipitation"
    
    // MARK: - Widget
    static let widgetMin = "widget_min"
    static let widgetMax = "widget_max"
    static let widgetHourlyForecast = "widget_hourly_forecast"
    static let widgetHumidity = "widget_humidity"
    static let widgetWind = "widget_wind"
    static let widgetPressure = "widget_pressure"
    
    // MARK: - Onboarding
    static let onboardingTitle1 = "onboarding_title_1"
    static let onboardingDesc1 = "onboarding_desc_1"
    static let onboardingTitle2 = "onboarding_title_2"
    static let onboardingDesc2 = "onboarding_desc_2"
    static let onboardingTitle3 = "onboarding_title_3"
    static let onboardingDesc3 = "onboarding_desc_3"
    static let onboardingTitle4 = "onboarding_title_4"
    static let onboardingDesc4 = "onboarding_desc_4"
    static let onboardingTitle5 = "onboarding_title_5"
    static let onboardingDesc5 = "onboarding_desc_5"
    static let onboardingSkip = "onboarding_skip"
    static let onboardingNext = "onboarding_next"
    static let onboardingStart = "onboarding_start"
    
    // MARK: - Splash Screen
    static let splashSubtitle = "splash_subtitle"

    // MARK: - Notifications
    static let notificationsWeatherAlerts = "notifications_weather_alerts"
    static let notificationsWeatherAlertsSubtitle = "notifications_weather_alerts_subtitle"

    // MARK: - Widget Location
    static let widgetLocation = "widget_location"
    static let widgetLocationAuto = "widget_location_auto"

    // MARK: - Insights Tab
    static let insightsTab = "insights_tab"

    // MARK: - Outfit
    static let outfitTitle = "outfit_title"
    static let outfitNoData = "outfit_no_data"
    static let outfitHeavyCoat = "outfit_heavy_coat"
    static let outfitCoat = "outfit_coat"
    static let outfitJacket = "outfit_jacket"
    static let outfitTshirt = "outfit_tshirt"
    static let outfitLight = "outfit_light"
    static let outfitUmbrella = "outfit_umbrella"
    static let outfitBoots = "outfit_boots"
    static let outfitSunglasses = "outfit_sunglasses"
    static let outfitWindbreaker = "outfit_windbreaker"
    static let outfitGloves = "outfit_gloves"
    static let outfitSunscreen = "outfit_sunscreen"

    // MARK: - Activities
    static let activityTitle = "activity_title"
    static let activityCanDo = "activity_can_do"
    static let activityAvoid = "activity_avoid"
    static let activityRunning = "activity_running"
    static let activityCycling = "activity_cycling"
    static let activityHiking = "activity_hiking"
    static let activitySkiing = "activity_skiing"
    static let activityBeach = "activity_beach"
    static let activityPhotography = "activity_photography"
    static let activityPicnic = "activity_picnic"

    // MARK: - Sunrise / Sunset
    static let sunrise = "sunrise"
    static let sunset = "sunset"

    // MARK: - UV & Smart Alerts
    static let rainStartingToggle = "rain_starting_toggle"

    static let uvReminderTitle = "uv_reminder_title"
    static let uvReminderToggle = "uv_reminder_toggle"
    static let uvDescLow = "uv_desc_low"
    static let uvDescModerate = "uv_desc_moderate"
    static let uvDescHigh = "uv_desc_high"
    static let uvDescVeryHigh = "uv_desc_very_high"
    static let uvDescExtreme = "uv_desc_extreme"
    static let smartAlertsTitle = "smart_alerts_title"
    static let dailySummaryTitle = "daily_summary_title"
    static let dailySummaryToggle = "daily_summary_toggle"
    static let dailySummaryTime = "daily_summary_time"

    // MARK: - Live Activity
    static let liveActivity = "live_activity"

    // MARK: - AQI
    static let aqiLabel = "aqi_label"
}
