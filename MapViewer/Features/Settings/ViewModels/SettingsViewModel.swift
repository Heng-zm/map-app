//
//  SettingsViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI
import CoreLocation
import Observation

/// ViewModel managing user preferences, units, appearance, coordinate formats, and cache management.
@Observable
@MainActor
public final class SettingsViewModel {
    private var repository: SettingsRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let searchHistoryRepository: SearchHistoryRepositoryProtocol
    
    public var coordinateFormat: CoordinateFormat {
        didSet { repository.coordinateFormat = coordinateFormat }
    }
    
    public var unitSystem: UnitSystem {
        didSet { repository.unitSystem = unitSystem }
    }
    
    public var mapStyle: MapStyleOption {
        didSet { repository.mapStyle = mapStyle }
    }
    
    public var mapElevation: MapElevation {
        didSet { repository.mapElevation = mapElevation }
    }
    
    public var showsTraffic: Bool {
        didSet { repository.showsTraffic = showsTraffic }
    }
    
    public var showsBuildings: Bool {
        didSet { repository.showsBuildings = showsBuildings }
    }
    
    public var showsCompass: Bool {
        didSet { repository.showsCompass = showsCompass }
    }
    
    public var showsScale: Bool {
        didSet { repository.showsScale = showsScale }
    }
    
    public var appearance: AppAppearance {
        didSet { repository.appearance = appearance }
    }
    
    public var followUserOnLaunch: Bool {
        didSet { repository.followUserOnLaunch = followUserOnLaunch }
    }
    
    public var showClearHistoryAlert: Bool = false
    public var clearHistorySuccessMessage: String?
    
    public var locationPermissionDescription: String {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse:
            return "Allowed While Using App"
        case .authorizedAlways:
            return "Always Allowed"
        case .denied:
            return "Denied (Open Settings to enable)"
        case .restricted:
            return "Restricted by Device Policy"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }
    
    public var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    public init(
        repository: SettingsRepositoryProtocol,
        locationService: LocationServiceProtocol,
        searchHistoryRepository: SearchHistoryRepositoryProtocol
    ) {
        self.repository = repository
        self.locationService = locationService
        self.searchHistoryRepository = searchHistoryRepository
        
        self.coordinateFormat = repository.coordinateFormat
        self.unitSystem = repository.unitSystem
        self.mapStyle = repository.mapStyle
        self.mapElevation = repository.mapElevation
        self.showsTraffic = repository.showsTraffic
        self.showsBuildings = repository.showsBuildings
        self.showsCompass = repository.showsCompass
        self.showsScale = repository.showsScale
        self.appearance = repository.appearance
        self.followUserOnLaunch = repository.followUserOnLaunch
    }
    
    public func clearSearchHistory() {
        do {
            try searchHistoryRepository.clearAll()
            self.clearHistorySuccessMessage = "Search history successfully cleared."
        } catch {
            self.clearHistorySuccessMessage = "Failed to clear history."
        }
    }
}
