//
//  DailyDetailView.swift
//  Skyrift
//

import SwiftUI
import Charts

struct DailyDetailView: View {
    let forecast: DailyForecast
    let hourlyForecasts: [HourlyForecast]
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("temperatureUnit") private var temperatureUnitRaw = TemperatureUnit.celsius.rawValue
    
    // Filtrelenmiş veri - init'te hazır
    private let filteredHourly: [HourlyForecast]
    
    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRaw) ?? .celsius
    }
    
    init(forecast: DailyForecast, hourlyForecasts: [HourlyForecast]) {
        self.forecast = forecast
        self.hourlyForecasts = hourlyForecasts
        
        // DEBUG: Gelen veri
        print("🔍 DailyDetailView Init")
        print("📅 Seçilen gün: \(forecast.date)")
        print("⏰ Toplam hourly veri: \(hourlyForecasts.count)")
        
        // Filtrelemeyi hemen yap
        let calendar = Calendar.current
        self.filteredHourly = hourlyForecasts.filter { hourly in
            calendar.isDate(hourly.time, inSameDayAs: forecast.date)
        }
        
        print("✅ Filtrelenen veri: \(self.filteredHourly.count)")
        if self.filteredHourly.isEmpty {
            print("⚠️ UYARI: Filtrelenen veri BOŞ!")
            print("📊 İlk 3 hourly tarih:")
            for (index, hourly) in hourlyForecasts.prefix(3).enumerated() {
                print("  \(index): \(hourly.time)")
            }
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.currentLocale
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: forecast.date)
    }
    
    private var condition: WeatherCondition {
        WeatherCondition.from(code: forecast.weatherCode)
    }
    
    // 24 saat formatı helper
    private func formatHour24(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    var body: some View {
        let _ = print("🎨 DailyDetailView body render - filteredHourly: \(filteredHourly.count)")
        
        return NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: []) {
                    // Üst özet kartı
                    summaryCard
                    
                    // Grafikler
                    if !filteredHourly.isEmpty {
                        let _ = print("✅ Grafikler gösteriliyor")
                        temperatureChart
                        precipitationChart
                        windChart
                        humidityChart
                        hourlyDetailTable
                    } else if hourlyForecasts.isEmpty {
                        let _ = print("⚠️ hourlyForecasts BOŞ - Loading gösteriliyor")
                        // Veri yükleniyor
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text(L10n.loadingHourly.localized)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        let _ = print("❌ Filtrelenmiş veri BOŞ - Hata mesajı gösteriliyor")
                        // Saatlik veri yok (bu gün için)
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text(L10n.noHourlyData.localized)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            .navigationTitle(dayName)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.close.localized) { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        HStack(spacing: 20) {
            // Icon ve açıklama
            VStack(spacing: 8) {
                Image(systemName: condition.symbolName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text(condition.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Sıcaklık ve stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Text(String(format: "%.0f%@", temperatureUnit.convert(forecast.maxTemp), temperatureUnit.symbol))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text(String(format: "%.0f%@", temperatureUnit.convert(forecast.minTemp), temperatureUnit.symbol))
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    Label(String(format: "%.1f mm", forecast.precipitationSum), systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Label(String(format: "%.0f km/s", forecast.maxWindSpeed), systemImage: "wind")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
                
                // UV Index
                Label(String(format: "UV %.0f", forecast.uvIndexMax), systemImage: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - Temperature Chart
    
    private var temperatureChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.temperatureChange.localized)
                .font(.headline)
                .padding(.horizontal)
            
            Chart(filteredHourly) { hourly in
                LineMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Sıcaklık", temperatureUnit.convert(hourly.temperature))
                )
                .foregroundStyle(.orange.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Sıcaklık", temperatureUnit.convert(hourly.temperature))
                )
                .foregroundStyle(.orange.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let temp = value.as(Double.self) {
                            Text("\(Int(temp))\(temperatureUnit.symbol)")
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Precipitation Chart
    
    private var precipitationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.precipitationProbability.localized)
                .font(.headline)
                .padding(.horizontal)
            
            Chart(filteredHourly) { hourly in
                BarMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Olasılık", hourly.precipitationProbability)
                )
                .foregroundStyle(.blue.gradient)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let percent = value.as(Int.self) {
                            Text("\(percent)%")
                        }
                    }
                }
            }
            .frame(height: 180)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Wind Chart
    
    private var windChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.windSpeed.localized)
                .font(.headline)
                .padding(.horizontal)
            
            Chart(filteredHourly) { hourly in
                LineMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Hız", hourly.windSpeed)
                )
                .foregroundStyle(.cyan.gradient)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let speed = value.as(Double.self) {
                            Text("\(Int(speed)) km/s")
                        }
                    }
                }
            }
            .frame(height: 160)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Humidity Chart
    
    private var humidityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.humidityLevel.localized)
                .font(.headline)
                .padding(.horizontal)
            
            Chart(filteredHourly) { hourly in
                AreaMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Nem", hourly.humidity)
                )
                .foregroundStyle(.teal.opacity(0.3).gradient)
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Saat", hourly.time, unit: .hour),
                    y: .value("Nem", hourly.humidity)
                )
                .foregroundStyle(.teal.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let humidity = value.as(Int.self) {
                            Text("\(humidity)%")
                        }
                    }
                }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 160)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Hourly Detail Table
    
    private var hourlyDetailTable: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.hourlyDetail.localized)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(L10n.hour.localized).frame(width: 50, alignment: .leading)
                    Text(L10n.temperature.localized).frame(width: 70, alignment: .center)
                    Text(L10n.precipitation.localized).frame(width: 60, alignment: .center)
                    Text(L10n.wind.localized).frame(width: 70, alignment: .center)
                    Text(L10n.humidity.localized).frame(width: 50, alignment: .trailing)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.quaternary.opacity(0.5))
                
                Divider()
                
                // Rows
                ForEach(filteredHourly.prefix(24)) { hourly in
                    HStack {
                        Text(formatHour24(hourly.time))
                            .frame(width: 50, alignment: .leading)
                        
                        Text(String(format: "%.0f%@", temperatureUnit.convert(hourly.temperature), temperatureUnit.symbol))
                            .fontWeight(.medium)
                            .frame(width: 70, alignment: .center)
                        
                        Text("\(hourly.precipitationProbability)%")
                            .foregroundStyle(hourly.precipitationProbability > 50 ? .blue : .secondary)
                            .frame(width: 60, alignment: .center)
                        
                        Text(String(format: "%.0f", hourly.windSpeed))
                            .frame(width: 70, alignment: .center)
                        
                        Text("\(hourly.humidity)%")
                            .frame(width: 50, alignment: .trailing)
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    if hourly.id != filteredHourly.prefix(24).last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}


