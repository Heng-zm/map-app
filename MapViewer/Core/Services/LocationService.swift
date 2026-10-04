//
//  LocationService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import Observation

/// Protocol declaring the contract for location updates, authorization, and heading.
@MainActor
public protocol LocationServiceProtocol: AnyObject, Sendable {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    var currentCoordinate: CLLocationCoordinate2D? { get }
    var currentHeading: CLHeading? { get }
    var isLocationServicesEnabled: Bool { get }
    var isUpdatingLocation: Bool { get }
    var errorMessage: String? { get }
    
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestSingleLocation() async throws -> CLLocation
}

/// Production implementation of LocationService using CLLocationManager and Observation.
@Observable
@MainActor
public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    
    public private(set) var authorizationStatus: CLAuthorizationStatus
    public private(set) var currentLocation: CLLocation?
    public private(set) var currentHeading: CLHeading?
    public private(set) var isLocationServicesEnabled: Bool
    public private(set) var isUpdatingLocation: Bool = false
    public private(set) var errorMessage: String?
    
    private var singleLocationContinuation: CheckedContinuation<CLLocation, Error>?
    
    public var currentCoordinate: CLLocationCoordinate2D? {
        currentLocation?.coordinate
    }
    
    public override init() {
        let manager = CLLocationManager()
        self.locationManager = manager
        self.authorizationStatus = manager.authorizationStatus
        self.isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
        
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5.0 // Update every 5 meters to conserve battery
        manager.headingFilter = 3.0  // Update heading every 3 degrees
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .otherNavigation
    }
    
    /// Requests when-in-use location permission.
    public func requestWhenInUseAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else {
            self.errorMessage = "Location Services are disabled on this device."
            return
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts battery-conscious location and heading tracking.
    public func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            self.errorMessage = "Location Services are disabled on this device."
            return
        }
        
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    /// Stops continuous location and heading tracking to save battery.
    public func stopUpdatingLocation() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    /// Asynchronously requests a single high-accuracy location fix.
    public func requestSingleLocation() async throws -> CLLocation {
        guard CLLocationManager.locationServicesEnabled() else {
            throw MapViewerError.locationServicesDisabled
        }
        
        switch authorizationStatus {
        case .denied:
            throw MapViewerError.locationPermissionDenied
        case .restricted:
            throw MapViewerError.locationPermissionRestricted
        case .notDetermined:
            requestWhenInUseAuthorization()
        default:
            break
        }
        
        if let existing = currentLocation, existing.timestamp.timeIntervalSinceNow > -15.0 {
            return existing
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.singleLocationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.errorMessage = nil
                if self.isUpdatingLocation {
                    manager.startUpdatingLocation()
                }
            case .denied:
                self.errorMessage = "Location access was denied. Please enable it in Settings."
                self.singleLocationContinuation?.resume(throwing: MapViewerError.locationPermissionDenied)
                self.singleLocationContinuation = nil
            case .restricted:
                self.errorMessage = "Location access is restricted on this device."
                self.singleLocationContinuation?.resume(throwing: MapViewerError.locationPermissionRestricted)
                self.singleLocationContinuation = nil
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            self.errorMessage = nil
            
            WidgetDataSyncService.shared.syncLocation(
                coordinate: location.coordinate,
                altitude: location.altitude,
                heading: self.currentHeading?.trueHeading
            )
            
            if let continuation = self.singleLocationContinuation {
                continuation.resume(returning: location)
                self.singleLocationContinuation = nil
            }
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.currentHeading = newHeading
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.errorMessage = "Location permission denied."
                    self.singleLocationContinuation?.resume(throwing: MapViewerError.locationPermissionDenied)
                case .locationUnknown:
                    self.errorMessage = "Location currently unknown."
                    self.singleLocationContinuation?.resume(throwing: MapViewerError.locationUnavailable)
                case .network:
                    self.errorMessage = "Network error while obtaining location."
                    self.singleLocationContinuation?.resume(throwing: MapViewerError.networkUnavailable)
                default:
                    self.errorMessage = error.localizedDescription
                    self.singleLocationContinuation?.resume(throwing: MapViewerError.locationUnavailable)
                }
            } else {
                self.errorMessage = error.localizedDescription
                self.singleLocationContinuation?.resume(throwing: error)
            }
            self.singleLocationContinuation = nil
        }
    }
}
