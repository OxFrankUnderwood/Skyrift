# Skyrift — Weather App

A clean, native weather app for iOS, macOS, and visionOS built entirely with SwiftUI and Apple WeatherKit. No third-party dependencies, no API keys required.

---

## Features

### Current Weather & Forecasts
- Real-time conditions: temperature, feels-like, humidity, wind speed & compass direction
- 10-day daily forecast with expandable detail views
- Hourly forecast chart — temperature curve + precipitation probability bars
- UV index, visibility, atmospheric pressure, cloud cover, sunrise & sunset

### Smart Insights
- **Outfit recommendations** — clothing suggestions based on temperature and conditions
- **Activity recommendations** — what to do (or avoid) based on the weather
- **UV monitor** — color-coded scale with protection advice

### Notifications & Live Activity
- Severe weather alerts (thunderstorm, heavy rain, snow, freezing conditions, fog)
- Rain-starting-soon warnings (checks the next 2 hours)
- UV index reminders
- Daily morning weather summary at a custom time
- Live Activity on the Dynamic Island / Lock Screen

### Widget Suite
- Small, Medium, and Large home screen widgets
- Inline lock screen widget
- 15-minute refresh interval via App Groups

### Multi-Location Support
- Save and switch between multiple cities
- Automatic current location detection
- Full-text location search via Open-Meteo Geocoding (no API key)

---

## Platforms

| Platform | Minimum |
|----------|---------|
| iOS | 26.2 |
| macOS | 26.2 |
| visionOS | 26.2 |

---

## Localization

8 languages supported with runtime switching (no app restart needed):

English · Turkish · German · French · Italian · Spanish · Portuguese · Russian

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI | SwiftUI |
| Weather data | Apple WeatherKit |
| Location search | Open-Meteo Geocoding API |
| Charts | Swift Charts |
| Architecture | MVVM + `@Observable` |
| Background refresh | BGAppRefreshTask |
| Notifications | UNUserNotificationCenter |
| Widgets | WidgetKit + App Groups |
| No external packages | Pure Apple frameworks |

---

## Build

Open `Skyrift.xcodeproj` in Xcode, select the **Skyrift** scheme, and run.

WeatherKit requires an active Apple Developer account with the WeatherKit entitlement enabled for your App ID.

```bash
# Debug build (command line)
xcodebuild -project Skyrift.xcodeproj -scheme Skyrift \
  -configuration Debug build

# Release build
xcodebuild -project Skyrift.xcodeproj -scheme Skyrift \
  -configuration Release build
```

---

## Architecture

```
SkyriftApp
├── SplashScreenView
├── OnboardingView          # 5-page first-run experience
└── ContentView             # TabView root
    ├── WeatherView         # Conditions, hourly & daily forecasts
    ├── LocationSearchView  # Search & manage saved locations
    ├── InsightsView        # Outfit, activity & UV recommendations
    └── SettingsView        # Units, appearance, language, notifications

Services/
├── WeatherService          # WeatherKit integration
├── LocationManager         # CoreLocation wrapper
└── NotificationManager     # Alerts, Live Activity, BGAppRefreshTask

SkyriftWidget/              # WidgetKit extension (Small / Medium / Large / Inline)
```

---

## License

This project is for personal and educational use.
