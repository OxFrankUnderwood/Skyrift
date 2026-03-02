//
//  DailyForecastRow.swift
//  Skyrift
//

import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast
    @AppStorage("temperatureUnit") private var temperatureUnitRaw = TemperatureUnit.celsius.rawValue
    
    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRaw) ?? .celsius
    }
    
    // Sıcaklığı formatla ve -0 sorununu düzelt
    private func formatTemperature(_ celsius: Double) -> String {
        let converted = temperatureUnit.convert(celsius)
        let rounded = Int(converted.rounded())
        // -0 veya +0 kontrolü
        let value = rounded == 0 ? 0 : rounded
        return "\(value)"
    }

    private var condition: WeatherCondition {
        WeatherCondition.from(code: forecast.weatherCode)
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.currentLocale
        formatter.dateFormat = "EEEE"
        return formatter.string(from: forecast.date).capitalized
    }

    var body: some View {
        HStack(spacing: 16) {
            // Gün adı - Minimalist
            Text(dayName)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .frame(width: 100, alignment: .leading)

            Spacer()
            
            // Hava durumu ikonu - Renkli
            Image(systemName: condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .foregroundStyle(iconColor(for: forecast.weatherCode))
                .frame(width: 32)

            // Yağış olasılığı ve UV
            VStack(spacing: 2) {
                if forecast.precipitationProbability > 20 {
                    HStack(spacing: 3) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 9))
                        Text("\(forecast.precipitationProbability)%")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(.blue.opacity(0.8))
                }
                
                if forecast.uvIndexMax > 3 {
                    HStack(spacing: 3) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 9))
                        Text(String(format: "%.0f", forecast.uvIndexMax))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(.orange.opacity(0.8))
                }
            }
            .frame(width: 40)

            // Sıcaklık aralığı - Sabit genişlik, derece simgesi ayrı
            HStack(spacing: 8) {
                // Min sıcaklık
                HStack(spacing: 2) {
                    Text(formatTemperature(forecast.minTemp))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fontWeight(.regular)
                        .monospacedDigit()
                    Text(temperatureUnit.symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 45, alignment: .trailing)
                
                // Max sıcaklık
                HStack(spacing: 2) {
                    Text(formatTemperature(forecast.maxTemp))
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    Text(temperatureUnit.symbol)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                .frame(width: 50, alignment: .trailing)
            }
            .fontDesign(.rounded)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Icon Color
    
    private func iconColor(for code: Int) -> Color {
        switch code {
        case 0, 1: return .yellow // Açık/Güneşli
        case 2: return .orange // Parçalı bulutlu
        case 3: return .gray // Bulutlu
        case 45, 48: return .gray.opacity(0.7) // Sisli
        case 51...57: return .cyan // Çisenti
        case 61...67: return .blue // Yağmurlu
        case 71...86: return .white // Karlı
        case 95...99: return .purple // Fırtına
        default: return .blue
        }
    }
}
