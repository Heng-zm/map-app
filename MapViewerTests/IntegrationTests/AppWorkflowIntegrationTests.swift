//
//  AppWorkflowIntegrationTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
import SwiftData
@testable import MapViewer

@MainActor
final class AppWorkflowIntegrationTests: XCTestCase {
    private var environment: AppEnvironment!
    
    override func setUp() async throws {
        try await super.setUp()
        environment = AppEnvironment.preview()
    }
    
    override func tearDown() async throws {
        environment = nil
        try await super.tearDown()
    }
    
    func testPinDropSaveAndRetrievalWorkflow() async throws {
        let deps = environment.dependencies
        let mapVM = MapViewModel(
            locationService: deps.locationService,
            geocodingService: deps.geocodingService,
            savedLocationRepository: deps.savedLocationRepository,
            settingsRepository: deps.settingsRepository
        )
        
        let dropCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let pin = LocationPin(
            coordinate: dropCoord,
            title: "Market Street Pin",
            subtitle: "San Francisco, CA",
            notes: "Meeting point for walking tour",
            colorHex: "#007AFF",
            isFavorite: true
        )
        
        // 1. Save pin
        mapVM.saveCustomPin(pin)
        XCTAssertEqual(mapVM.customPins.count, 1)
        XCTAssertEqual(mapVM.customPins.first?.title, "Market Street Pin")
        
        // 2. Verify stored in SwiftData repository
        let persisted = try deps.savedLocationRepository.fetchAllPins()
        XCTAssertEqual(persisted.count, 1)
        XCTAssertEqual(persisted.first?.title, "Market Street Pin")
        XCTAssertTrue(persisted.first!.isFavorite)
        
        // 3. Delete pin
        mapVM.deleteCustomPin(pin)
        XCTAssertTrue(mapVM.customPins.isEmpty)
        let afterDelete = try deps.savedLocationRepository.fetchAllPins()
        XCTAssertTrue(afterDelete.isEmpty)
    }
    
    func testMeasurementWorkflow() {
        let deps = environment.dependencies
        let measurementVM = MeasurementViewModel(
            measurementService: deps.measurementService,
            settingsRepository: deps.settingsRepository
        )
        
        // Initial state
        XCTAssertEqual(measurementVM.points.count, 0)
        XCTAssertEqual(measurementVM.result.totalDistance, 0)
        
        // Add 3 waypoints
        let p1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let p2 = CLLocationCoordinate2D(latitude: 37.7759, longitude: -122.4194)
        let p3 = CLLocationCoordinate2D(latitude: 37.7759, longitude: -122.4184)
        
        measurementVM.addPoint(p1)
        XCTAssertEqual(measurementVM.points.count, 1)
        
        measurementVM.addPoint(p2)
        XCTAssertEqual(measurementVM.points.count, 2)
        XCTAssertGreaterThan(measurementVM.result.totalDistance, 50.0)
        XCTAssertEqual(measurementVM.result.segmentDistances.count, 1)
        
        measurementVM.addPoint(p3)
        XCTAssertEqual(measurementVM.points.count, 3)
        XCTAssertEqual(measurementVM.result.segmentDistances.count, 2)
        
        // Switch to polygon area
        measurementVM.toggleMode()
        XCTAssertEqual(measurementVM.mode, .area)
        XCTAssertGreaterThan(measurementVM.result.polygonArea, 0.0)
        
        // Undo last point
        measurementVM.undoLastPoint()
        XCTAssertEqual(measurementVM.points.count, 2)
        
        // Clear all
        measurementVM.clear()
        XCTAssertEqual(measurementVM.points.count, 0)
        XCTAssertEqual(measurementVM.result.totalDistance, 0.0)
    }
}
