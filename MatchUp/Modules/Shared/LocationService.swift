//
//  LocationService.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 14/01/2025.
//

import Foundation
import MapKit
import CoreLocation

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        // locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(from eventLocation: CLLocation) -> Double? {
        guard let currentLocation = currentLocation else { return nil }
        return currentLocation.distance(from: eventLocation) / 1000
    }
    
    func geocode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
        
    func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [placemark.thoroughfare, placemark.subThoroughfare, placemark.locality]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
    
    func reverseGeocodeFullAddress(location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [placemark.thoroughfare, placemark.subThoroughfare, placemark.subLocality, placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
    
    func getCityFromLocation(_ location: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality
        } catch {
            print("Failed to get city from location: \(error.localizedDescription)")
            return nil
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Location update failed: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location permissions denied or restricted.")
            currentLocation = nil
        case .notDetermined:
            print("Location permissions not determined yet.")
        @unknown default:
            print("Unhandled authorization status.")
        }
    }
}
