//
//  WeatherView.swift
//  Skyrift
//

import SwiftUI

struct WeatherView: View {
    var viewModel: WeatherViewModel
    var locationManager: LocationManager

    @State private var showLocationSearch = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if let weather = viewModel.weatherData {
                    weatherContent(weather: weather)
                } else {
                    emptyView
                }
            }
            .navigationTitle(viewModel.selectedLocation?.name ?? "Skyrift")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showLocationSearch = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchView(viewModel: viewModel, locationManager: locationManager)
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Hava durumu yükleniyor...")
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
            Button("Tekrar Dene") {
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
            Text("Hava durumu için bir konum seçin")
                .foregroundStyle(.secondary)
            Button("Konumumu Kullan") {
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
            VStack(spacing: 24) {
                currentWeatherCard(weather.current)

                Divider()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 0) {
                    Text("7 Günlük Tahmin")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    ForEach(weather.daily) { day in
                        DailyForecastRow(forecast: day)
                            .padding(.horizontal)
                        if day.id != weather.daily.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Current Weather Card

    private func currentWeatherCard(_ current: CurrentWeather) -> some View {
        let condition = WeatherCondition.from(code: current.weatherCode, isDay: current.isDay == 1)

        return VStack(spacing: 12) {
            Image(systemName: condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 80))

            Text(String(format: "%.0f°", current.temperature))
                .font(.system(size: 72, weight: .thin))

            Text(condition.description)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                weatherDetailItem(
                    icon: "thermometer.medium",
                    value: String(format: "%.0f°", current.apparentTemperature),
                    label: "Hissedilen"
                )
                weatherDetailItem(
                    icon: "humidity.fill",
                    value: "\(current.humidity)%",
                    label: "Nem"
                )
                weatherDetailItem(
                    icon: "wind",
                    value: String(format: "%.0f km/s", current.windSpeed),
                    label: "Rüzgar"
                )
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
    }

    private func weatherDetailItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
