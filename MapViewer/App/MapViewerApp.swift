//
//  MapViewerApp.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import SwiftData

@main
struct MapViewerApp: App {
    @State private var environment: AppEnvironment
    
    // ViewModels
    @State private var mapViewModel: MapViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var savedLocationsViewModel: SavedLocationsViewModel
    @State private var routeViewModel: RouteViewModel
    @State private var measurementViewModel: MeasurementViewModel
    @State private var settingsViewModel: SettingsViewModel
    
    init() {
        let env = AppEnvironment()
        self._environment = State(initialValue: env)
        
        let deps = env.dependencies
        
        let mapVM = MapViewModel(
            locationService: deps.locationService,
            geocodingService: deps.geocodingService,
            savedLocationRepository: deps.savedLocationRepository,
            settingsRepository: deps.settingsRepository
        )
        let searchVM = SearchViewModel(
            searchService: deps.searchService,
            searchHistoryRepository: deps.searchHistoryRepository
        )
        let savedLocVM = SavedLocationsViewModel(
            repository: deps.savedLocationRepository,
            locationService: deps.locationService
        )
        let routeVM = RouteViewModel(
            routingService: deps.routingService,
            locationService: deps.locationService
        )
        let measurementVM = MeasurementViewModel(
            measurementService: deps.measurementService,
            settingsRepository: deps.settingsRepository
        )
        let settingsVM = SettingsViewModel(
            repository: deps.settingsRepository,
            locationService: deps.locationService,
            searchHistoryRepository: deps.searchHistoryRepository
        )
        
        self._mapViewModel = State(initialValue: mapVM)
        self._searchViewModel = State(initialValue: searchVM)
        self._savedLocationsViewModel = State(initialValue: savedLocVM)
        self._routeViewModel = State(initialValue: routeVM)
        self._measurementViewModel = State(initialValue: measurementVM)
        self._settingsViewModel = State(initialValue: settingsVM)
    }
    
    var body: some Scene {
        WindowGroup {
            AdaptiveRootView(
                mapViewModel: mapViewModel,
                searchViewModel: searchViewModel,
                savedLocationsViewModel: savedLocationsViewModel,
                routeViewModel: routeViewModel,
                measurementViewModel: measurementViewModel,
                settingsViewModel: settingsViewModel
            )
            .preferredColorScheme(settingsViewModel.appearance.colorScheme)
            .modelContainer(environment.modelContainer)
        }
    }
}
