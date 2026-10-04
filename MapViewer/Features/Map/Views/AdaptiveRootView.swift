//
//  AdaptiveRootView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Adaptive navigation container providing NavigationSplitView on iPad and full-screen map on iPhone.
public struct AdaptiveRootView: View {
    @Bindable public var mapViewModel: MapViewModel
    @Bindable public var searchViewModel: SearchViewModel
    @Bindable public var savedLocationsViewModel: SavedLocationsViewModel
    @Bindable public var routeViewModel: RouteViewModel
    @Bindable public var measurementViewModel: MeasurementViewModel
    @Bindable public var settingsViewModel: SettingsViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSidebarItem: SidebarItem? = .map
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    public enum SidebarItem: String, CaseIterable, Identifiable {
        case map = "Map Explorer"
        case search = "Search Places"
        case saved = "Saved Locations"
        case routes = "Route Planner"
        case measure = "Measurement Tool"
        case settings = "Settings"
        
        public var id: String { rawValue }
        
        public var iconName: String {
            switch self {
            case .map: return "map.fill"
            case .search: return "magnifyingglass"
            case .saved: return "bookmark.fill"
            case .routes: return "arrow.triangle.turn.up.right.diamond.fill"
            case .measure: return "ruler.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    public init(
        mapViewModel: MapViewModel,
        searchViewModel: SearchViewModel,
        savedLocationsViewModel: SavedLocationsViewModel,
        routeViewModel: RouteViewModel,
        measurementViewModel: MeasurementViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        self.mapViewModel = mapViewModel
        self.searchViewModel = searchViewModel
        self.savedLocationsViewModel = savedLocationsViewModel
        self.routeViewModel = routeViewModel
        self.measurementViewModel = measurementViewModel
        self.settingsViewModel = settingsViewModel
    }
    
    public var body: some View {
        if horizontalSizeClass == .regular {
            // iPad / Large screen layout with NavigationSplitView
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(selection: $selectedSidebarItem) {
                    Section("Navigation") {
                        ForEach(SidebarItem.allCases) { item in
                            NavigationLink(value: item) {
                                Label {
                                    HStack {
                                        Text(item.rawValue)
                                        Spacer()
                                        if item == .saved && !savedLocationsViewModel.locations.isEmpty {
                                            Text("\(savedLocationsViewModel.locations.count)")
                                                .font(.caption2.bold())
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.secondary.opacity(0.12), in: Capsule())
                                        }
                                    }
                                } icon: {
                                    Image(systemName: item.iconName)
                                }
                            }
                        }
                    }
                    
                    Section("Current Map Center") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(CoordinateFormatter.shared.format(mapViewModel.currentCenter, format: settingsViewModel.coordinateFormat))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Button("Copy Coordinates") {
                                UIPasteboard.general.string = CoordinateFormatter.shared.formatRawDecimal(mapViewModel.currentCenter)
                            }
                            .font(.caption.bold())
                            .padding(.top, 2)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .navigationTitle("Map Viewer")
                .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 360)
            } content: {
                // Secondary Content Panel for iPad
                Group {
                    switch selectedSidebarItem {
                    case .search:
                        SearchSheetView(viewModel: searchViewModel) { place in
                            mapViewModel.selectPlace(place)
                        }
                    case .saved:
                        SavedLocationsListView(
                            viewModel: savedLocationsViewModel,
                            userCoordinate: mapViewModel.currentCenter,
                            unitSystem: settingsViewModel.unitSystem,
                            onSelectLocation: { loc in
                                mapViewModel.moveToCoordinate(loc.coordinate)
                            }
                        )
                    case .routes:
                        RoutePlanningSheetView(
                            viewModel: routeViewModel,
                            unitSystem: settingsViewModel.unitSystem,
                            onApplyRoute: { route in
                                mapViewModel.activeRoute = route
                                if let first = route.polylineCoordinates.first {
                                    mapViewModel.moveToCoordinate(first)
                                }
                            }
                        )
                    case .measure:
                        List {
                            Section("Measurement Mode") {
                                Picker("Measurement Mode", selection: $measurementViewModel.mode) {
                                    ForEach(MeasurementMode.allCases) { m in
                                        Label(m.displayName, systemImage: m.iconName).tag(m)
                                    }
                                }
                                .pickerStyle(.inline)
                            }
                            
                            Section("Calculation Results") {
                                MeasurementSummaryCard(
                                    result: measurementViewModel.result,
                                    mode: measurementViewModel.mode,
                                    unitSystem: settingsViewModel.unitSystem
                                )
                            }
                            
                            Section {
                                Button("Activate Measurement on Map") {
                                    mapViewModel.isMeasuringMode = true
                                    selectedSidebarItem = .map
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .navigationTitle("Measurement")
                    case .settings:
                        SettingsView(viewModel: settingsViewModel)
                    case .map, .none:
                        MainMapView(
                            mapViewModel: mapViewModel,
                            searchViewModel: searchViewModel,
                            savedLocationsViewModel: savedLocationsViewModel,
                            routeViewModel: routeViewModel,
                            measurementViewModel: measurementViewModel,
                            settingsViewModel: settingsViewModel
                        )
                    }
                }
            } detail: {
                // Detail Map View on iPad
                MainMapView(
                    mapViewModel: mapViewModel,
                    searchViewModel: searchViewModel,
                    savedLocationsViewModel: savedLocationsViewModel,
                    routeViewModel: routeViewModel,
                    measurementViewModel: measurementViewModel,
                    settingsViewModel: settingsViewModel
                )
            }
        } else {
            // iPhone Portrait / Compact Layout
            MainMapView(
                mapViewModel: mapViewModel,
                searchViewModel: searchViewModel,
                savedLocationsViewModel: savedLocationsViewModel,
                routeViewModel: routeViewModel,
                measurementViewModel: measurementViewModel,
                settingsViewModel: settingsViewModel
            )
        }
    }
}
