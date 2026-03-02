//
//  LocationManager.swift
//  Skyrift
//
//  iOS 26+ compatible - Uses MapKit for reverse geocoding instead of CLGeocoder
//

import CoreLocation
import Observation
import MapKit

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    var coordinate: CLLocationCoordinate2D?
    var cityName: String = ""
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
        // Önceki oturumdan kalan konumu anında yayınla
        if let lastLocation = manager.location {
            coordinate = lastLocation.coordinate
        }
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
#if os(macOS)
            manager.requestAlwaysAuthorization()
#else
            manager.requestWhenInUseAuthorization()
#endif
        case .authorizedAlways:
            manager.requestLocation()
#if !os(macOS)
        case .authorizedWhenInUse:
            manager.requestLocation()
#endif
        default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        let isAuthorized: Bool
#if os(macOS)
        isAuthorized = (authorizationStatus == .authorizedAlways)
#else
        isAuthorized = (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
#endif
        if isAuthorized {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        coordinate = location.coordinate
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error: \(error.localizedDescription)")
    }

    private func reverseGeocode(location: CLLocation) {
        // iOS 26+ MapKit kullanımı
        Task {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            searchRequest.resultTypes = .address
            searchRequest.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            
            let search = MKLocalSearch(request: searchRequest)
            
            do {
                let response = try await search.start()
                if let mapItem = response.mapItems.first {
                    await MainActor.run {
                        self.cityName = mapItem.placemark.locality 
                            ?? mapItem.placemark.administrativeArea 
                            ?? mapItem.name
                            ?? "Bilinmeyen Konum"
                    }
                }
            } catch {
                print("Reverse geocode error: \(error.localizedDescription)")
                await MainActor.run {
                    self.cityName = L10n.currentLocation.localized
                }
            }
        }
    }
}
