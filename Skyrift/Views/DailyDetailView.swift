//
//  DailyDetailView.swift
//  Skyrift
//

import SwiftUI

struct DailyDetailView: View {
    let forecast: DailyForecast
    let hourlyForecasts: [HourlyForecast]
    @Environment(\.dismiss) private var dismiss
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: forecast.date)
    }
    
    private var condition: WeatherCondition {
        WeatherCondition.from(code: forecast.weatherCode)
    }
    
    // Sadece seçilen güne ait saatlik tahminleri filtrele
    private var filteredHourly: [HourlyForecast] {
        let calendar = Calendar.current
        return hourlyForecasts.filter { hourly in
            calendar.isDate(hourly.time, inSameDayAs: forecast.date)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Gün özeti
                    VStack(spacing: 12) {
                        Image(systemName: condition.symbolName)
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 60))
                        
                        Text(condition.description)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 8) {
                            Text(String(format: "%.0f°", forecast.maxTemp))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("/")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f°", forecast.minTemp))
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    
                    // Genel bilgiler
                    VStack(spacing: 0) {
                        DetailRow(
                            icon: "drop.fill",
                            title: "Yağış",
                            value: String(format: "%.1f mm", forecast.precipitationSum),
                            color: .blue
                        )
                        Divider().padding(.leading, 50)
                        
                        DetailRow(
                            icon: "wind",
                            title: "Maksimum Rüzgar",
                            value: String(format: "%.0f km/s", forecast.maxWindSpeed),
                            color: .cyan
                        )
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Saatlik tahminler
                    if !filteredHourly.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saatlik Tahmin")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(filteredHourly) { hourly in
                                        HourlyCard(forecast: hourly)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 30)
            
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
        .padding()
    }
}

// MARK: - Hourly Card

struct HourlyCard: View {
    let forecast: HourlyForecast
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: forecast.time)
    }
    
    private var condition: WeatherCondition {
        // Saat 6-18 arası gündüz, diğerleri gece olarak kabul et
        let hour = Calendar.current.component(.hour, from: forecast.time)
        let isDay = (6...18).contains(hour)
        return WeatherCondition.from(code: forecast.weatherCode, isDay: isDay)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(timeString)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Image(systemName: condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)
            
            Text(String(format: "%.0f°", forecast.temperature))
                .font(.headline)
            
            // Yağış olasılığı
            if forecast.precipitationProbability > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                    Text("\(forecast.precipitationProbability)%")
                        .font(.caption2)
                }
                .foregroundStyle(.blue)
            }
            
            // Rüzgar hızı
            HStack(spacing: 2) {
                Image(systemName: "wind")
                    .font(.caption2)
                Text(String(format: "%.0f", forecast.windSpeed))
                    .font(.caption2)
            }
            .foregroundStyle(.cyan)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
