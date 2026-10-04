//
//  MainMapView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import MapKit
import CoreLocation

/// Full-screen production MapKit view featuring real MapKit layers, annotations, gestures, and overlays.
public struct MainMapView: View {
    @Bindable public var mapViewModel: MapViewModel
    @Bindable public var searchViewModel: SearchViewModel
    @Bindable public var savedLocationsViewModel: SavedLocationsViewModel
    @Bindable public var routeViewModel: RouteViewModel
    @Bindable public var measurementViewModel: MeasurementViewModel
    @Bindable public var settingsViewModel: SettingsViewModel
    
    // Sheet presentation states
    @State private var isSearchSheetPresented: Bool = false
    @State private var isSavedPlacesPresented: Bool = false
    @State private var isRouteSheetPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var isShowingRouteStepsSheet: Bool = false
    
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // MapKit Canvas
                MapReader { proxy in
                    Map(
                        position: $mapViewModel.cameraPosition,
                        interactionModes: .all
                    ) {
                        // User location indicator
                        UserAnnotation()
                        
                        // Custom User Pins
                        ForEach(mapViewModel.customPins) { pin in
                            Annotation(pin.title, coordinate: pin.coordinate) {
                                CustomPinAnnotationView(
                                    pin: pin,
                                    isSelected: mapViewModel.selectedPin?.id == pin.id,
                                    onTap: {
                                        mapViewModel.selectPin(pin)
                                    }
                                )
                            }
                        }
                        
                        // Selected Search Place Marker
                        if let place = mapViewModel.selectedPlace {
                            Marker(place.name, systemImage: "mappin.circle.fill", coordinate: place.coordinate)
                                .tint(.red)
                        }
                        
                        // Route Polyline and Endpoints
                        if let route = mapViewModel.activeRoute {
                            MapPolyline(coordinates: route.polylineCoordinates)
                                .stroke(.blue, lineWidth: 6)
                            
                            if let startCoord = route.polylineCoordinates.first {
                                Marker("Start", systemImage: "figure.walk", coordinate: startCoord)
                                    .tint(.green)
                            }
                            
                            if let endCoord = route.polylineCoordinates.last {
                                Marker("Destination", systemImage: "flag.checkered", coordinate: endCoord)
                                    .tint(.red)
                            }
                        }
                        
                        // Measurement Overlays
                        if mapViewModel.isMeasuringMode {
                            if measurementViewModel.coordinates.count >= 2 {
                                MapPolyline(coordinates: measurementViewModel.coordinates)
                                    .stroke(.indigo, style: StrokeStyle(lineWidth: 4, dash: [6, 4]))
                            }
                            
                            if measurementViewModel.mode == .area && measurementViewModel.coordinates.count >= 3 {
                                MapPolygon(coordinates: measurementViewModel.coordinates)
                                    .foregroundStyle(.indigo.opacity(0.25))
                                    .stroke(.indigo, lineWidth: 2)
                            }
                            
                            ForEach(measurementViewModel.points) { pt in
                                Annotation("Point \(pt.index)", coordinate: pt.coordinate) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.indigo)
                                            .frame(width: 26, height: 26)
                                            .shadow(color: .black.opacity(0.3), radius: 3)
                                        Text("\(pt.index)")
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .mapStyle(
                        mapViewModel.mapStyleOption.toMapStyle(
                            elevation: mapViewModel.mapElevation,
                            showsTraffic: mapViewModel.showsTraffic
                        )
                    )
                    .mapControls {
                        if mapViewModel.showsCompass { MapCompass() }
                        if mapViewModel.showsScale { MapScaleView() }
                    }
                    .onMapCameraChange(frequency: .continuous) { context in
                        mapViewModel.visibleRegion = context.region
                        mapViewModel.currentCenter = context.region.center
                        searchViewModel.activeRegion = context.region
                    }
                    .onTapGesture { screenPoint in
                        if mapViewModel.isMeasuringMode, let coord = proxy.convert(screenPoint, from: .local) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            measurementViewModel.addPoint(coord)
                        } else {
                            // Tap on empty space clears selection
                            mapViewModel.selectedPin = nil
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if let point = drag?.location, let coord = proxy.convert(point, from: .local) {
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                        mapViewModel.handleLongPress(at: coord)
                                    }
                                default:
                                    break
                                }
                            }
                    )
                }
                .ignoresSafeArea()
                
                // Top Overlay: Search Bar & Settings Button
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Button(action: { isSearchSheetPresented = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Search places, addresses...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .glassBackground(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Search places and addresses")
                        
                        Button(action: { isSettingsPresented = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .glassBackground(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open Settings")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    Spacer()
                }
                
                // Right Overlay: Floating Map Controls
                HStack {
                    Spacer()
                    FloatingMapControls(
                        is3D: mapViewModel.mapElevation == .realistic,
                        isTrafficEnabled: mapViewModel.showsTraffic,
                        isMeasuring: mapViewModel.isMeasuringMode,
                        hasActiveRoute: mapViewModel.activeRoute != nil,
                        onLocateMe: { mapViewModel.centerOnUserLocation() },
                        onZoomIn: { mapViewModel.zoomIn() },
                        onZoomOut: { mapViewModel.zoomOut() },
                        onToggle3D: { mapViewModel.toggleElevation() },
                        onToggleTraffic: { mapViewModel.toggleTraffic() },
                        onOpenStylePicker: { mapViewModel.isStylePickerPresented = true },
                        onToggleMeasure: {
                            mapViewModel.isMeasuringMode.toggle()
                            if !mapViewModel.isMeasuringMode {
                                measurementViewModel.clear()
                            }
                        },
                        onOpenRoutes: { isRouteSheetPresented = true },
                        onOpenSaved: { isSavedPlacesPresented = true },
                        onOpenSettings: { isSettingsPresented = true }
                    )
                }
                .padding(.top, 70)
                
                // Bottom Overlay: Coordinates Badge, Route Overview, or Measurement Control Bar
                VStack(spacing: 8) {
                    Spacer()
                    
                    if mapViewModel.isMeasuringMode {
                        MeasurementControlBar(
                            mode: $measurementViewModel.mode,
                            pointCount: measurementViewModel.points.count,
                            primaryValue: measurementViewModel.formattedPrimaryValue,
                            secondaryValue: measurementViewModel.formattedSecondaryValue,
                            onUndo: { measurementViewModel.undoLastPoint() },
                            onClear: { measurementViewModel.clear() },
                            onDone: {
                                mapViewModel.isMeasuringMode = false
                                measurementViewModel.clear()
                            }
                        )
                    } else if let activeRoute = mapViewModel.activeRoute {
                        RouteOverviewCard(
                            route: activeRoute,
                            unitSystem: settingsViewModel.unitSystem,
                            onOpenSteps: { isShowingRouteStepsSheet = true },
                            onClearRoute: { mapViewModel.clearActiveRoute() }
                        )
                    } else {
                        CoordinateDisplayBadge(
                            coordinate: mapViewModel.currentCenter,
                            format: settingsViewModel.coordinateFormat
                        )
                    }
                }
                .padding(.bottom, 16)
            }
        }
        // Modals & Bottom Sheets
        .sheet(isPresented: $isSearchSheetPresented) {
            SearchSheetView(viewModel: searchViewModel) { selectedPlace in
                mapViewModel.selectPlace(selectedPlace)
            }
        }
        .sheet(isPresented: $mapViewModel.isPlaceDetailSheetPresented) {
            if let place = mapViewModel.selectedPlace {
                let isFav = savedLocationsViewModel.locations.contains(where: {
                    $0.latitude == place.coordinate.latitude && $0.longitude == place.coordinate.longitude && $0.isFavorite
                })
                
                PlaceDetailSheetView(
                    place: place,
                    userCoordinate: mapViewModel.currentCenter,
                    coordinateFormat: settingsViewModel.coordinateFormat,
                    unitSystem: settingsViewModel.unitSystem,
                    isFavorite: isFav,
                    onToggleFavorite: {
                        if let saved = savedLocationsViewModel.locations.first(where: {
                            $0.latitude == place.coordinate.latitude && $0.longitude == place.coordinate.longitude
                        }) {
                            savedLocationsViewModel.toggleFavorite(saved)
                        } else {
                            savedLocationsViewModel.saveLocation(
                                name: place.name,
                                notes: "",
                                coordinate: place.coordinate,
                                address: place.address,
                                category: place.category ?? "Personal",
                                isFavorite: true
                            )
                        }
                    },
                    onSavePlace: {
                        savedLocationsViewModel.saveLocation(
                            name: place.name,
                            notes: "",
                            coordinate: place.coordinate,
                            address: place.address,
                            category: place.category ?? "Personal",
                            isFavorite: false
                        )
                    },
                    onDirections: {
                        routeViewModel.setDestination(coordinate: place.coordinate, name: place.name)
                        mapViewModel.isPlaceDetailSheetPresented = false
                        isRouteSheetPresented = true
                    },
                    onDismiss: {
                        mapViewModel.isPlaceDetailSheetPresented = false
                    }
                )
            }
        }
        .sheet(item: $mapViewModel.editingPin) { pin in
            PinEditSheetView(
                pin: pin,
                isNewPin: !mapViewModel.customPins.contains(where: { $0.id == pin.id }),
                onSave: { updatedPin in
                    mapViewModel.saveCustomPin(updatedPin)
                    mapViewModel.editingPin = nil
                },
                onDelete: { pinToDelete in
                    mapViewModel.deleteCustomPin(pinToDelete)
                    mapViewModel.editingPin = nil
                }
            )
        }
        .sheet(isPresented: $mapViewModel.isStylePickerPresented) {
            MapStylePickerSheet(
                selectedStyle: $mapViewModel.mapStyleOption,
                elevation: $mapViewModel.mapElevation,
                showsTraffic: $mapViewModel.showsTraffic,
                showsBuildings: $mapViewModel.showsBuildings,
                showsCompass: $mapViewModel.showsCompass,
                showsScale: $mapViewModel.showsScale
            )
        }
        .sheet(isPresented: $isSavedPlacesPresented) {
            SavedLocationsListView(
                viewModel: savedLocationsViewModel,
                userCoordinate: mapViewModel.currentCenter,
                unitSystem: settingsViewModel.unitSystem,
                onSelectLocation: { saved in
                    mapViewModel.moveToCoordinate(saved.coordinate)
                }
            )
        }
        .sheet(isPresented: $isRouteSheetPresented) {
            RoutePlanningSheetView(
                viewModel: routeViewModel,
                unitSystem: settingsViewModel.unitSystem,
                onApplyRoute: { selectedRoute in
                    mapViewModel.activeRoute = selectedRoute
                    if let first = selectedRoute.polylineCoordinates.first {
                        mapViewModel.moveToCoordinate(first, latitudinalMeters: selectedRoute.distance * 1.2, longitudinalMeters: selectedRoute.distance * 1.2)
                    }
                }
            )
        }
        .sheet(isPresented: $isShowingRouteStepsSheet) {
            if let activeRoute = mapViewModel.activeRoute {
                NavigationStack {
                    ScrollView {
                        RouteStepDetailView(steps: activeRoute.steps, unitSystem: settingsViewModel.unitSystem)
                    }
                    .navigationTitle("Turn-by-Turn")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                isShowingRouteStepsSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(viewModel: settingsViewModel)
        }
        .alert("Map Notice", isPresented: $mapViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(mapViewModel.alertMessage ?? "An unexpected event occurred.")
        }
    }
}
