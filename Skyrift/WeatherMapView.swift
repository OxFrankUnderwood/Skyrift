//
//  WeatherMapView.swift
//  Skyrift
//
//  Radar haritası görünümü
//

import SwiftUI
import MapKit

struct WeatherMapView: View {
    let location: WeatherLocation
    @Environment(\.dismiss) private var dismiss
    
    @State private var mapType: MapType = .precipitation
    @State private var region: MapCameraPosition
    
    init(location: WeatherLocation) {
        self.location = location
        _region = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )))
    }
    
    enum MapType: String, CaseIterable, Identifiable {
        case precipitation = "Yağış"
        case temperature = "Sıcaklık"
        case clouds = "Bulutlar"
        case wind = "Rüzgar"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .precipitation: return "cloud.rain.fill"
            case .temperature: return "thermometer.medium"
            case .clouds: return "cloud.fill"
            case .wind: return "wind"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Harita
                Map(position: $region) {
                    Marker(location.name, coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ))
                    .tint(.blue)
                }
                .mapStyle(.standard(elevation: .realistic))
                
                // Overlay - Radar katmanı (görsel simülasyon)
                radarOverlay
                
                // Alt kontroller
                VStack {
                    Spacer()
                    
                    controlPanel
                        .padding()
                }
            }
            .navigationTitle("Radar Haritası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Radar Overlay
    
    private var radarOverlay: some View {
        VStack {
            // Üst bilgi kartı
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                    Text(mapType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: mapType.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Control Panel
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            // Map type seçici
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MapType.allCases) { type in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                mapType = type
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 16))
                                Text(type.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                mapType == type
                                    ? Color.blue
                                    : Color.clear
                            )
                            .foregroundStyle(mapType == type ? .white : .primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.blue.opacity(0.5), lineWidth: mapType == type ? 0 : 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Zoom kontrolleri
            HStack(spacing: 16) {
                Button {
                    // Zoom kontrollerini MapCameraPosition API ile yap
                    region = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                    ))
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                Button {
                    region = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                    ))
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                Button {
                    region = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                    ))
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    WeatherMapView(location: WeatherLocation(
        name: "İstanbul, Türkiye",
        latitude: 41.0082,
        longitude: 28.9784
    ))
}
