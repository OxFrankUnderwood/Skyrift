//
//  DailyForecastRow.swift
//  Skyrift
//

import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast

    private var condition: WeatherCondition {
        WeatherCondition.from(code: forecast.weatherCode)
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: forecast.date).capitalized
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(dayName)
                .frame(width: 100, alignment: .leading)
                .foregroundStyle(.primary)

            Image(systemName: condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .frame(width: 28)

            Spacer()

            if forecast.precipitationSum > 0 {
                Label(String(format: "%.0f mm", forecast.precipitationSum), systemImage: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            HStack(spacing: 4) {
                Text(String(format: "%.0f°", forecast.minTemp))
                    .foregroundStyle(.secondary)
                Text("/")
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f°", forecast.maxTemp))
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 6)
    }
}
