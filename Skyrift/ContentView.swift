//
//  ContentView.swift
//  Skyrift
//
//  Created by Emre on 22.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var locationManager = LocationManager()

    var body: some View {
        WeatherView(viewModel: viewModel, locationManager: locationManager)
            .task {
                // Auto-load current location on first launch if no saved location is selected
                if viewModel.selectedLocation == nil {
                    locationManager.requestLocation()
                    try? await Task.sleep(for: .seconds(2))
                    if viewModel.selectedLocation == nil {
                        await viewModel.selectCurrentLocation(locationManager: locationManager)
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
