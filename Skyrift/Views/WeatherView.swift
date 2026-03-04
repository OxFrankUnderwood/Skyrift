//
//  WeatherView.swift
//  Skyrift
//

import Charts
import SwiftUI
import WeatherKit

struct WeatherView: View {
    var viewModel: WeatherViewModel
    var locationManager: LocationManager

    @State private var selectedDayForecast: DailyForecast?
    @State private var currentLocationIndex = 0
    @State private var indexChangeTask: Task<Void, Never>?  // Debounce için
    @State private var iconFloating = false
    @State private var gradientShifting = false
    @AppStorage("enableAnimations") private var enableAnimations = true
    @AppStorage("temperatureUnit") private var temperatureUnitRaw = TemperatureUnit.celsius.rawValue
    @Environment(\.colorScheme) private var colorScheme
    
    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRaw) ?? .celsius
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan
                if let weather = viewModel.weatherData, enableAnimations {
                    WeatherBackgroundView(
                        weatherCode: weather.current.weatherCode,
                        isDay: weather.current.isDay == 1
                    )
                    .opacity(0.3)
                    .allowsHitTesting(false)
                }
                
                // İçerik
                contentView
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let cityName = viewModel.selectedLocation?.cityName {
                        if #available(iOS 26, *) {
                            Text(cityName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .glassEffect(.regular.tint(.blue.opacity(0.1)), in: .capsule)
                        } else {
                            Text(cityName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: .capsule)
                        }
                    }
                }
            }
            .sheet(item: $selectedDayForecast) { selectedDay in
                // Sheet açıldığında viewModel'dan CANLI veriyi al
                if let currentWeather = viewModel.weatherData {
                    DailyDetailView(
                        forecast: selectedDay,
                        hourlyForecasts: currentWeather.hourly,
                        attribution: viewModel.weatherAttribution
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThinMaterial)
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if allLocations.isEmpty {
            emptyView
        } else if allLocations.count == 1 {
            // Tek konum - TabView yok
            locationWeatherView(for: allLocations[0])
        } else {
            // Çoklu konum - paging
            #if DEBUG
            let _ = print("🔄 ContentView render - Konum sayısı: \(allLocations.count), Mevcut index: \(currentLocationIndex)")
            #endif
            
            TabView(selection: $currentLocationIndex) {
                ForEach(Array(allLocations.enumerated()), id: \.element.id) { index, location in
                    locationWeatherView(for: location)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onChange(of: currentLocationIndex) { oldValue, newValue in
                #if DEBUG
                print("📍 Index değişti: \(oldValue) → \(newValue)")
                #endif

                // Önceki task'ı iptal et
                indexChangeTask?.cancel()

                guard oldValue != newValue,
                      newValue >= 0,
                      newValue < allLocations.count else {
                    #if DEBUG
                    print("⚠️ Geçersiz index değişimi!")
                    #endif
                    return
                }

                // Debounce: 300ms bekle, ardından yükle
                let location = allLocations[newValue]
                indexChangeTask = Task { @MainActor in
                    do {
                        try await Task.sleep(for: .milliseconds(300))
                        #if DEBUG
                        print("✅ Index sabitlendi, veri yükleniyor: \(newValue)")
                        #endif
                        if location.isCurrentLocation {
                            await viewModel.selectCurrentLocation(locationManager: locationManager)
                        } else {
                            await viewModel.loadWeather(for: location)
                        }
                    } catch {
                        // Task cancelled - normal
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var allLocations: [WeatherLocation] {
        viewModel.savedLocations
    }
    
    // MARK: - Location Weather View
    
    @ViewBuilder
    private func locationWeatherView(for location: WeatherLocation) -> some View {
        if let weather = viewModel.weatherData, viewModel.selectedLocation?.id == location.id {
            weatherContent(weather: weather)
        } else if viewModel.isLoading && viewModel.selectedLocation?.id == location.id {
            loadingView
        } else if let error = viewModel.errorMessage, viewModel.selectedLocation?.id == location.id {
            errorView(message: error)
        } else {
            loadingView
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(L10n.loadingWeather.localized)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(L10n.retry.localized) {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .symbolRenderingMode(.multicolor)
            Text(L10n.selectLocation.localized)
                .foregroundStyle(.secondary)
            Button(L10n.useMyLocation.localized) {
                locationManager.requestLocation()
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    await viewModel.selectCurrentLocation(locationManager: locationManager)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Weather Content

    private func weatherContent(weather: WeatherData) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVStack(spacing: 24, pinnedViews: []) {
                    currentWeatherCard(weather)

                    // Yeni Özellikler - Grid Layout
                    additionalInfoGrid(weather: weather)

                    Divider()
                        .padding(.horizontal)

                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(weather.daily.prefix(10))) { day in
                            Button {
                                #if DEBUG
                                print("🔘 Günlük detay tıklandı: \(day.date)")
                                print("📦 weather.hourly sayısı: \(weather.hourly.count)")
                                #endif

                                // Sadece günü seç - sheet kendi verisini alacak
                                selectedDayForecast = day
                                #if DEBUG
                                print("✅ selectedDayForecast set edildi")
                                #endif
                            } label: {
                                DailyForecastRow(forecast: day)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)

                            if day.id != weather.daily.prefix(10).last?.id {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                }

                appleWeatherAttribution
            }
            .padding(.top, 100) // Navigation bar için üst boşluk
            .padding(.vertical)
            .padding(.bottom, 80) // Tab bar için alt boşluk
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Current Weather Card

    private func currentWeatherCard(_ weather: WeatherData) -> some View {
        let current = weather.current
        let condition = WeatherCondition.from(code: current.weatherCode, isDay: current.isDay == 1, customText: current.conditionText)
        let gradientColors = weatherGradient(for: current.weatherCode, isDay: current.isDay == 1)

        return VStack(spacing: 20) {
            // Ana hava durumu bilgisi - Gradient arka plan ile
            VStack(spacing: 16) {
                Image(systemName: condition.symbolName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 120))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .offset(y: iconFloating ? -10 : 0)
                    .scaleEffect(iconFloating ? 1.05 : 1.0)
                    .symbolEffect(.pulse, options: .repeating, isActive: enableAnimations)

                Text(String(format: "%.0f%@", temperatureUnit.convert(current.temperature), temperatureUnit.symbol))
                    .font(.system(size: 90, weight: .thin))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.6), value: current.temperature)

                Text(condition.description)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.9))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: condition.description)

                // 12 saatlik inline grafik
                inlineHourlyChart(hourly: weather.hourly)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: gradientShifting ? .top : .topLeading,
                    endPoint: gradientShifting ? .bottomTrailing : .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 20, x: 0, y: 10)

            // Detay bilgileri - Modern kartlar
            HStack(spacing: 12) {
                weatherDetailItem(
                    icon: "thermometer.medium",
                    value: String(format: "%.0f%@", temperatureUnit.convert(current.apparentTemperature), temperatureUnit.symbol),
                    label: L10n.feelsLike.localized,
                    gradient: [Color(red: 1.0, green: 0.4, blue: 0.3), Color(red: 1.0, green: 0.6, blue: 0.2)]
                )

                weatherDetailItem(
                    icon: "humidity.fill",
                    value: "\(current.humidity)%",
                    label: L10n.humidity.localized,
                    gradient: [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.3, green: 0.7, blue: 1.0)]
                )

                weatherDetailItem(
                    icon: "wind",
                    value: String(format: "%.0f km/h", current.windSpeed),
                    label: L10n.wind.localized,
                    gradient: [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.5, green: 0.9, blue: 0.7)],
                    badge: compassDirection(current.windDirection)
                )
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            guard enableAnimations else { return }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                iconFloating = true
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                gradientShifting = true
            }
        }
    }

    // MARK: - Apple Weather Attribution

    @ViewBuilder
    private var appleWeatherAttribution: some View {
        if let attribution = viewModel.weatherAttribution {
            let markURL = colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL
            VStack(spacing: 12) {
                Divider()
                    .padding(.horizontal)

                Link(destination: attribution.legalPageURL) {
                    AsyncImage(url: markURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Text("Weather")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 16)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Wind Direction

    // MARK: - Cached Formatters

    private static let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private func compassDirection(_ degrees: Int) -> String {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(degrees) / 45.0).rounded()) % 8
        return dirs[index]
    }

    private func timeOfDay(_ date: Date) -> String {
        Self.hourFormatter.locale = LanguageManager.shared.currentLocale
        return Self.hourFormatter.string(from: date)
    }

    // MARK: - Inline Hourly Chart

    @ViewBuilder
    private func inlineHourlyChart(hourly: [HourlyForecast]) -> some View {
        let now = Date()
        let points = Array(hourly.filter { $0.time >= now }.prefix(13))
        if points.isEmpty {
            EmptyView()
        } else {
            let temps = points.map { temperatureUnit.convert($0.temperature) }
            let minTemp = (temps.min() ?? 0) - 2
            let maxTemp = (temps.max() ?? 0) + 2
            let startTime = points.first!.time
            let endTime = points.last!.time

            VStack(spacing: 0) {
                // Temperature chart
                Chart(points) { point in
                    AreaMark(
                        x: .value("Saat", point.time),
                        yStart: .value("Min", minTemp),
                        yEnd: .value("Sıcaklık", temperatureUnit.convert(point.temperature))
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Saat", point.time),
                        y: .value("Sıcaklık", temperatureUnit.convert(point.temperature))
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.white.opacity(0.9))
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Saat", point.time),
                        y: .value("Sıcaklık", temperatureUnit.convert(point.temperature))
                    )
                    .foregroundStyle(Color.white)
                    .symbolSize(14)

                    PointMark(
                        x: .value("Saat", point.time),
                        y: .value("Sıcaklık", temperatureUnit.convert(point.temperature))
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .top, spacing: 4) {
                        Text(String(format: "%.0f%@", temperatureUnit.convert(point.temperature), temperatureUnit.symbol))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .chartYScale(domain: minTemp...maxTemp)
                .chartXScale(domain: startTime...endTime)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(height: 90)
                .padding(.horizontal, 12)

                // Precipitation probability bars
                Chart(points) { point in
                    BarMark(
                        x: .value("Saat", point.time, unit: .hour),
                        y: .value("Yağış %", Double(point.precipitationProbability))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.75), Color.blue.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartYScale(domain: 0...100)
                .chartXScale(domain: startTime...endTime)
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(hourLabel(date))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
    }

    private func hourLabel(_ date: Date) -> String {
        Self.hourFormatter.string(from: date)
    }

    // Hava durumuna göre gradient renkleri
    private func weatherGradient(for code: Int, isDay: Bool) -> [Color] {
        switch code {
        case 0, 1: // Açık
            return isDay 
                ? [Color(red: 1.0, green: 0.75, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.3)] // Turuncu-sarı
                : [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.5)] // Gece mavisi
        case 2, 3: // Bulutlu
            return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.5, green: 0.6, blue: 0.7)]
        case 45, 48: // Sisli
            return [Color(red: 0.6, green: 0.65, blue: 0.7), Color(red: 0.7, green: 0.75, blue: 0.8)]
        case 51...67: // Yağmurlu
            return [Color(red: 0.2, green: 0.4, blue: 0.7), Color(red: 0.3, green: 0.3, blue: 0.6)]
        case 71...86: // Karlı
            return [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.9, blue: 1.0)]
        case 95...99: // Fırtınalı
            return [Color(red: 0.2, green: 0.2, blue: 0.4), Color(red: 0.4, green: 0.3, blue: 0.5)]
        default:
            return [Color.blue, Color.cyan]
        }
    }

    private func weatherDetailItem(icon: String, value: String, label: String, gradient: [Color], badge: String? = nil) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .frame(height: 40)

            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))

            Text(badge ?? " ")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(badge != nil ? 0.75 : 0))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(badge != nil ? 0.15 : 0), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            LinearGradient(
                colors: [
                    gradient.first ?? .blue,
                    gradient.last ?? .cyan
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: (gradient.first ?? .blue).opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Additional Info Grid
    
    private func additionalInfoGrid(weather: WeatherData) -> some View {
        VStack(spacing: 16) {
            // Birinci satır: UV Index, Görüş, Basınç
            HStack(spacing: 16) {
                infoCard(
                    icon: "sun.max.fill",
                    title: L10n.uvIndex.localized,
                    value: String(format: "%.0f", weather.current.uvIndex),
                    subtitle: uvCategory(weather.current.uvIndex),
                    color: uvColor(weather.current.uvIndex)
                )

                infoCard(
                    icon: "eye.fill",
                    title: L10n.visibility.localized,
                    value: String(format: "%.1f km", weather.current.visibility),
                    subtitle: visibilityCategory(weather.current.visibility),
                    color: visibilityColor(weather.current.visibility)
                )

                infoCard(
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    title: L10n.pressure.localized,
                    value: String(format: "%.0f hPa", weather.current.pressure),
                    subtitle: pressureCategory(weather.current.pressure),
                    color: pressureColor(weather.current.pressure)
                )
            }

            // İkinci satır: Güneş doğuşu, Güneş batışı, Bulutluluk
            if let today = weather.daily.first {
                HStack(spacing: 16) {
                    infoCard(
                        icon: "sunrise.fill",
                        title: L10n.sunrise.localized,
                        value: timeOfDay(today.sunrise),
                        subtitle: "",
                        color: .orange
                    )

                    infoCard(
                        icon: "sunset.fill",
                        title: L10n.sunset.localized,
                        value: timeOfDay(today.sunset),
                        subtitle: "",
                        color: Color(red: 0.55, green: 0.3, blue: 0.7)
                    )

                    infoCard(
                        icon: "cloud.fill",
                        title: L10n.cloudiness.localized,
                        value: "\(weather.current.cloudCover)%",
                        subtitle: cloudCategory(weather.current.cloudCover),
                        color: cloudColor(weather.current.cloudCover)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Info Cards
    
    private func infoCard(icon: String, title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .frame(height: 28)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.15), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [color.opacity(0.75), color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.25), radius: 10, x: 0, y: 5)
    }
    
    private func airQualityCard(airQuality: AirQuality, gradient: [Color]) -> some View {
        // AQI rengini al
        let color: Color
        switch airQuality.aqi {
        case 1: color = .green
        case 2, 3: color = .yellow
        case 4: color = .orange
        case 5: color = .red
        default: color = .gray
        }
        
        return VStack(spacing: 8) {
            Image(systemName: "aqi.medium")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .frame(height: 28)
            
            Text("\(L10n.aqiLabel.localized) \(airQuality.aqi)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(L10n.airQuality.localized)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
            
            Text(airQuality.category)
                .font(.system(size: 10))
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.15), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [color.opacity(0.75), color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.25), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Category Helpers
    
    private func uvCategory(_ uv: Double) -> String {
        switch uv {
        case 0..<3: return L10n.uvLow.localized
        case 3..<6: return L10n.uvModerate.localized
        case 6..<8: return L10n.uvHigh.localized
        case 8..<11: return L10n.uvVeryHigh.localized
        default: return L10n.uvExtreme.localized
        }
    }
    
    private func uvColor(_ uv: Double) -> Color {
        switch uv {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
    
    private func visibilityCategory(_ visibility: Double) -> String {
        switch visibility {
        case 0..<1: return L10n.visibilityVeryPoor.localized
        case 1..<4: return L10n.visibilityPoor.localized
        case 4..<10: return L10n.visibilityModerate.localized
        default: return L10n.visibilityGood.localized
        }
    }
    
    private func visibilityColor(_ visibility: Double) -> Color {
        switch visibility {
        case 0..<1: return .red
        case 1..<4: return .orange
        case 4..<10: return .yellow
        default: return .green
        }
    }
    
    private func pressureCategory(_ pressure: Double) -> String {
        switch pressure {
        case 0..<1000: return L10n.pressureLow.localized
        case 1000..<1020: return L10n.pressureNormal.localized
        default: return L10n.pressureHigh.localized
        }
    }
    
    private func pressureColor(_ pressure: Double) -> Color {
        switch pressure {
        case 0..<1000: return .blue
        case 1000..<1020: return .green
        default: return .orange
        }
    }
    
    private func cloudCategory(_ cloud: Int) -> String {
        switch cloud {
        case 0..<25: return L10n.cloudsFew.localized
        case 25..<50: return L10n.cloudsScattered.localized
        case 50..<75: return L10n.cloudsBroken.localized
        default: return L10n.cloudsOvercast.localized
        }
    }
    
    private func cloudColor(_ cloud: Int) -> Color {
        switch cloud {
        case 0..<25: return .cyan
        case 25..<50: return .blue
        case 50..<75: return .indigo
        default: return .gray
        }
    }
}
