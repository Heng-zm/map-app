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
    @State public var trackRecordingViewModel = TrackRecordingViewModel()
    
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
                        
                        // Live GPS Track Polyline
                        if trackRecordingViewModel.isRecording && trackRecordingViewModel.routeCoordinates.count >= 2 {
                            MapPolyline(coordinates: trackRecordingViewModel.routeCoordinates)
                                .stroke(Color.orange, lineWidth: 5)
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
                
                let safeTop = max(geometry.safeAreaInsets.top, 16)
                let safeBottom = max(geometry.safeAreaInsets.bottom, 16)
                let safeLeading = max(geometry.safeAreaInsets.leading, 16)
                let safeTrailing = max(geometry.safeAreaInsets.trailing, 16)
                let topBarHeight: CGFloat = 48
                let topControlsOffset = safeTop + 4 + topBarHeight + 10
                let bottomCardOffset = safeBottom + 6

                // Top Overlay: Search Bar & Quick Action Buttons (Respects Dynamic Island / Notch Safe Area)
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        Button(action: { isSearchSheetPresented = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Search places, addresses...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 14)
                            .frame(height: topBarHeight)
                            .glassBackground(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Search places and addresses")
                        
                        Button(action: { isSavedPlacesPresented = true }) {
                            ZStack {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                if !savedLocationsViewModel.locations.isEmpty {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 8, y: -8)
                                }
                            }
                            .frame(width: topBarHeight, height: topBarHeight)
                            .glassBackground(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Saved Places")
                        
                        Button(action: {
                            if trackRecordingViewModel.isRecording {
                                trackRecordingViewModel.stopRecording()
                            } else {
                                trackRecordingViewModel.startRecording()
                            }
                        }) {
                            Image(systemName: trackRecordingViewModel.isRecording ? "stop.circle.fill" : "record.circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(trackRecordingViewModel.isRecording ? .red : .primary)
                                .frame(width: topBarHeight, height: topBarHeight)
                                .glassBackground(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("GPS Track Recording")
                        
                        Button(action: { isSettingsPresented = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: topBarHeight, height: topBarHeight)
                                .glassBackground(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open Settings")
                    }
                    .padding(.horizontal, safeLeading)
                    .padding(.top, safeTop + 4)
                    
                    if trackRecordingViewModel.isRecording {
                        TrackRecordingHUDView(
                            viewModel: trackRecordingViewModel,
                            unitSystem: settingsViewModel.unitSystem
                        )
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                // Right Overlay: Floating Map Controls (Positioned Below Top Bar, Above Bottom Bar)
                HStack(spacing: 0) {
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
                    .padding(.trailing, safeTrailing)
                    .padding(.top, topControlsOffset)
                }
                
                // Bottom Overlay: Coordinates Badge, Route Overview, or Measurement Control Bar
                VStack(spacing: 0) {
                    Spacer()
                    
                    Group {
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
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else if let activeRoute = mapViewModel.activeRoute {
                            RouteOverviewCard(
                                route: activeRoute,
                                unitSystem: settingsViewModel.unitSystem,
                                onOpenSteps: { isShowingRouteStepsSheet = true },
                                onClearRoute: { mapViewModel.clearActiveRoute() }
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            CoordinateDisplayBadge(
                                coordinate: mapViewModel.currentCenter,
                                format: settingsViewModel.coordinateFormat
                            )
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, safeLeading)
                    .frame(maxWidth: 540)
                    .padding(.bottom, bottomCardOffset)
                }
                .frame(maxWidth: .infinity)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: mapViewModel.isMeasuringMode)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: mapViewModel.activeRoute != nil)
            }
        }
        // Modals & Bottom Sheets
        .sheet(isPresented: $isSearchSheetPresented) {
            SearchSheetView(viewModel: searchViewModel) { selectedPlace in
                mapViewModel.selectPlace(selectedPlace)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
                .presentationDetents([.fraction(0.38), .medium, .large])
                .presentationDragIndicator(.visible)
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
            .presentationDetents([.medium, .fraction(0.7)])
            .presentationDragIndicator(.visible)
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
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
        .sheet(isPresented: $trackRecordingViewModel.isDetailSheetPresented) {
            TrackDetailSheetView(
                track: $trackRecordingViewModel.completedTrack,
                unitSystem: settingsViewModel.unitSystem
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: mapViewModel.userLocation) { _, newLoc in
            if let loc = newLoc, trackRecordingViewModel.isRecording {
                trackRecordingViewModel.processLocationUpdate(loc)
            }
        }
        .alert("Map Notice", isPresented: $mapViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(mapViewModel.alertMessage ?? "An unexpected event occurred.")
        }
    }
}
