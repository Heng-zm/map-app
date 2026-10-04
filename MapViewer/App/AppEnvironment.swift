//
//  AppEnvironment.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData
import Observation

/// Bootstraps and manages production dependencies and SwiftData container.
@Observable
@MainActor
public final class AppEnvironment {
    public let modelContainer: ModelContainer
    public let dependencies: AppDependencies
    
    public init(inMemory: Bool = false) {
        do {
            let schema = Schema([
                SavedLocation.self,
                SearchHistoryItem.self,
                CustomPin.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container
            
            // Repositories
            let savedLocationRepo = SwiftDataSavedLocationRepository(modelContainer: container)
            let searchHistoryRepo = SwiftDataSearchHistoryRepository(modelContainer: container)
            let settingsRepo = UserDefaultsSettingsRepository()
            
            // Services
            let locationService = LocationService()
            let searchService = SearchService()
            let geocodingService = GeocodingService()
            let routingService = RoutingService()
            let measurementService = MeasurementService()
            
            self.dependencies = AppDependencies(
                locationService: locationService,
                searchService: searchService,
                geocodingService: geocodingService,
                routingService: routingService,
                measurementService: measurementService,
                savedLocationRepository: savedLocationRepo,
                searchHistoryRepository: searchHistoryRepo,
                settingsRepository: settingsRepo
            )
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    /// Factory for preview/testing environment using in-memory SwiftData.
    public static func preview() -> AppEnvironment {
        AppEnvironment(inMemory: true)
    }
}
