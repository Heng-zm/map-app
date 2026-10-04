//
//  AppDependencies.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData

/// Container protocol holding dependencies for clean dependency injection.
@MainActor
public struct AppDependencies: Sendable {
    public let locationService: LocationServiceProtocol
    public let searchService: SearchServiceProtocol
    public let geocodingService: GeocodingServiceProtocol
    public let routingService: RoutingServiceProtocol
    public let measurementService: MeasurementServiceProtocol
    public let savedLocationRepository: SavedLocationRepositoryProtocol
    public let searchHistoryRepository: SearchHistoryRepositoryProtocol
    public let settingsRepository: SettingsRepositoryProtocol
    
    public init(
        locationService: LocationServiceProtocol,
        searchService: SearchServiceProtocol,
        geocodingService: GeocodingServiceProtocol,
        routingService: RoutingServiceProtocol,
        measurementService: MeasurementServiceProtocol,
        savedLocationRepository: SavedLocationRepositoryProtocol,
        searchHistoryRepository: SearchHistoryRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.locationService = locationService
        self.searchService = searchService
        self.geocodingService = geocodingService
        self.routingService = routingService
        self.measurementService = measurementService
        self.savedLocationRepository = savedLocationRepository
        self.searchHistoryRepository = searchHistoryRepository
        self.settingsRepository = settingsRepository
    }
}
