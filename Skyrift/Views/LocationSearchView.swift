//
//  LocationSearchView.swift
//  Skyrift
//

import SwiftUI

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: WeatherViewModel
    var locationManager: LocationManager

    @State private var searchText = ""
    @State private var searchResults: [WeatherLocation] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var searchTask: Task<Void, Never>?

    private let service = WeatherService()

    var body: some View {
        NavigationStack {
            List {
                // Current location row
                Section {
                    Button {
                        locationManager.requestLocation()
                        Task {
                            try? await Task.sleep(for: .seconds(1))
                            await viewModel.selectCurrentLocation(locationManager: locationManager)
                            dismiss()
                        }
                    } label: {
                        Label("Mevcut Konumumu Kullan", systemImage: "location.fill")
                            .foregroundStyle(.blue)
                    }
                }

                // Saved locations
                if !viewModel.savedLocations.isEmpty {
                    Section("Kayıtlı Konumlar") {
                        ForEach(viewModel.savedLocations) { location in
                            Button {
                                Task {
                                    await viewModel.loadWeather(for: location)
                                    dismiss()
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(location.name)
                                            .foregroundStyle(.primary)
                                    }
                                    Spacer()
                                    if viewModel.selectedLocation?.id == location.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.removeLocation(at: offsets)
                        }
                    }
                }

                // Search results
                if !searchResults.isEmpty {
                    Section("Arama Sonuçları") {
                        ForEach(searchResults) { location in
                            Button {
                                viewModel.addLocation(location)
                                Task {
                                    await viewModel.loadWeather(for: location)
                                    dismiss()
                                }
                            } label: {
                                HStack {
                                    Text(location.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                if let error = searchError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Konumlar")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .searchable(text: $searchText, prompt: "Şehir veya ülke ara...")
            .onSubmit(of: .search) {
                searchTask?.cancel()
                performSearch()
            }
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                if newValue.isEmpty {
                    searchResults = []
                    searchError = nil
                    return
                }
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    guard !Task.isCancelled else { return }
                    performSearch()
                }
            }
            .overlay {
                if isSearching {
                    ProgressView()
                }
            }
        }
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchError = nil

        Task {
            do {
                searchResults = try await service.searchLocations(query: searchText)
                if searchResults.isEmpty {
                    searchError = "Sonuç bulunamadı."
                }
            } catch {
                searchError = "Arama başarısız: \(error.localizedDescription)"
            }
            isSearching = false
        }
    }
}
