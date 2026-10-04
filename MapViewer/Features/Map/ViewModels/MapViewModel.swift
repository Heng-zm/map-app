//
//  MapViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import Observation

/// ViewModel coordinating the full-screen MapKit view, camera positioning, pins, and map overlays.
@Observable
@MainActor
public final class MapViewModel {
    // MARK: - Dependencies
    private let locationService: LocationServiceProtocol
    private let geocodingService: GeocodingServiceProtocol
    private let savedLocationRepository: SavedLocationRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    
    // MARK: - Map State
    public var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion.defaultRegion)
    public var visibleRegion: MKCoordinateRegion = MKCoordinateRegion.defaultRegion
    public var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D.sanFrancisco
    public var userLocation: CLLocation? { locationService.currentLocation }
    public var userCoordinate: CLLocationCoordinate2D? { locationService.currentCoordinate }
    
    // Preferences & Layer Toggles
    public var mapStyleOption: MapStyleOption = .standard
    public var mapElevation: MapElevation = .realistic
    public var showsTraffic: Bool = false
    public var showsBuildings: Bool = true
    public var showsCompass: Bool = true
    public var showsScale: Bool = true
    public var followUserLocation: Bool = false
    
    // Pins & Selection
    public var customPins: [LocationPin] = []
    public var selectedPin: LocationPin?
    public var selectedPlace: PlaceSearchResult?
    public var editingPin: LocationPin?
    public var isPinEditSheetPresented: Bool = false
    public var isPlaceDetailSheetPresented: Bool = false
    public var isStylePickerPresented: Bool = false
    public var isSearchSheetPresented: Bool = false
    
    // Overlays
    public var activeRoute: RouteInfo?
    public var isMeasuringMode: Bool = false
    public var measurementPoints: [CLLocationCoordinate2D] = []
    public var measurementResult: MeasurementResult = .empty
    
    // UI Feedback
    public var alertMessage: String?
    public var showAlert: Bool = false
    public var isLoadingPinGeocode: Bool = false
    
    public init(
        locationService: LocationServiceProtocol,
        geocodingService: GeocodingServiceProtocol,
        savedLocationRepository: SavedLocationRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.savedLocationRepository = savedLocationRepository
        self.settingsRepository = settingsRepository
        
        loadPreferences()
        loadPersistedPins()
    }
    
    // MARK: - Preferences
    
    public func loadPreferences() {
        self.mapStyleOption = settingsRepository.mapStyle
        self.mapElevation = settingsRepository.mapElevation
        self.showsTraffic = settingsRepository.showsTraffic
        self.showsBuildings = settingsRepository.showsBuildings
        self.showsCompass = settingsRepository.showsCompass
        self.showsScale = settingsRepository.showsScale
        self.followUserLocation = settingsRepository.followUserOnLaunch
        
        if followUserLocation {
            centerOnUserLocation()
        }
    }
    
    public func updateMapStyle(_ style: MapStyleOption) {
        self.mapStyleOption = style
        var repo = settingsRepository
        repo.mapStyle = style
    }
    
    public func toggleTraffic() {
        showsTraffic.toggle()
        var repo = settingsRepository
        repo.showsTraffic = showsTraffic
    }
    
    public func toggleElevation() {
        mapElevation = (mapElevation == .realistic) ? .flat : .realistic
        var repo = settingsRepository
        repo.mapElevation = mapElevation
        
        let pitch: Double = (mapElevation == .realistic) ? 45.0 : 0.0
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: currentCenter, distance: 1500, heading: 0, pitch: pitch))
        }
    }
    
    // MARK: - Navigation & Camera
    
    public func centerOnUserLocation() {
        if let userCoord = locationService.currentCoordinate {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentCenter = userCoord
                cameraPosition = .region(MKCoordinateRegion(
                    center: userCoord,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))
            }
        } else {
            locationService.requestWhenInUseAuthorization()
            locationService.startUpdatingLocation()
            Task {
                do {
                    let loc = try await locationService.requestSingleLocation()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        self.currentCenter = loc.coordinate
                        self.cameraPosition = .region(MKCoordinateRegion(
                            center: loc.coordinate,
                            latitudinalMeters: 1000,
                            longitudinalMeters: 1000
                        ))
                    }
                } catch {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    public func moveToCoordinate(_ coordinate: CLLocationCoordinate2D, latitudinalMeters: Double = 1000, longitudinalMeters: Double = 1000) {
        guard coordinate.isValidCoordinate else { return }
        currentCenter = coordinate
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: latitudinalMeters,
                longitudinalMeters: longitudinalMeters
            ))
        }
    }
    
    public func setCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        moveToCoordinate(coordinate)
    }
    
    public func zoomIn() {
        let currentSpan = visibleRegion.span
        let newLatDelta = max(currentSpan.latitudeDelta * 0.5, 0.002)
        let newLonDelta = max(currentSpan.longitudeDelta * 0.5, 0.002)
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: currentCenter,
                span: MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
            ))
        }
    }
    
    public func zoomOut() {
        let currentSpan = visibleRegion.span
        let newLatDelta = min(currentSpan.latitudeDelta * 2.0, 120.0)
        let newLonDelta = min(currentSpan.longitudeDelta * 2.0, 120.0)
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: currentCenter,
                span: MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
            ))
        }
    }
    
    // MARK: - Custom Pin Handling
    
    public func loadPersistedPins() {
        do {
            let pins = try savedLocationRepository.fetchAllPins()
            self.customPins = pins.map { $0.toLocationPin() }
        } catch {
            self.alertMessage = "Failed to load pins: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
    
    public func handleLongPress(at coordinate: CLLocationCoordinate2D) {
        guard coordinate.isValidCoordinate else { return }
        isLoadingPinGeocode = true
        
        Task {
            var pinTitle = "Dropped Pin"
            var pinSubtitle: String? = nil
            
            do {
                let address = try await geocodingService.reverseGeocode(coordinate: coordinate)
                if let name = address.name, !name.isEmpty {
                    pinTitle = name
                } else if let street = address.street, !street.isEmpty {
                    pinTitle = street
                }
                pinSubtitle = address.formattedAddress
            } catch {
                pinSubtitle = String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
            }
            
            self.isLoadingPinGeocode = false
            let newPin = LocationPin(
                coordinate: coordinate,
                title: pinTitle,
                subtitle: pinSubtitle,
                notes: "",
                colorHex: "#FF3B30",
                isFavorite: false
            )
            
            self.editingPin = newPin
            self.isPinEditSheetPresented = true
        }
    }
    
    public func saveCustomPin(_ pin: LocationPin) {
        let persistentPin = CustomPin(
            id: pin.id,
            title: pin.title,
            subtitle: pin.subtitle,
            notes: pin.notes,
            latitude: pin.coordinate.latitude,
            longitude: pin.coordinate.longitude,
            colorHex: pin.colorHex,
            isFavorite: pin.isFavorite,
            createdAt: pin.createdAt,
            updatedAt: Date()
        )
        
        do {
            if let index = customPins.firstIndex(where: { $0.id == pin.id }) {
                customPins[index] = pin
                try savedLocationRepository.updatePin(persistentPin)
            } else {
                customPins.append(pin)
                try savedLocationRepository.savePin(persistentPin)
            }
        } catch {
            self.alertMessage = "Failed to save pin: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
    
    public func deleteCustomPin(_ pin: LocationPin) {
        customPins.removeAll(where: { $0.id == pin.id })
        if selectedPin?.id == pin.id {
            selectedPin = nil
        }
        
        let persistentPin = CustomPin(
            id: pin.id,
            title: pin.title,
            subtitle: pin.subtitle,
            notes: pin.notes,
            latitude: pin.coordinate.latitude,
            longitude: pin.coordinate.longitude,
            colorHex: pin.colorHex,
            isFavorite: pin.isFavorite,
            createdAt: pin.createdAt,
            updatedAt: pin.updatedAt
        )
        
        do {
            try savedLocationRepository.deletePin(persistentPin)
        } catch {
            self.alertMessage = "Failed to delete pin: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
    
    public func selectPlace(_ place: PlaceSearchResult) {
        self.selectedPlace = place
        self.selectedPin = nil
        self.isPlaceDetailSheetPresented = true
        moveToCoordinate(place.coordinate)
    }
    
    public func selectPin(_ pin: LocationPin) {
        self.selectedPin = pin
        self.selectedPlace = nil
        moveToCoordinate(pin.coordinate)
    }
    
    public func clearActiveRoute() {
        self.activeRoute = nil
    }
}
