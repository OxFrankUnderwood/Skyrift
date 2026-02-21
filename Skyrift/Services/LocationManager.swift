//
//  LocationManager.swift
//  Skyrift
//

import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    var coordinate: CLLocationCoordinate2D?
    var cityName: String = ""
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
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
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality ?? placemark.administrativeArea ?? "Bilinmeyen Konum"
            }
        }
    }
}
