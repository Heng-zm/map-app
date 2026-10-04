//
//  WidgetDataSyncTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
import SwiftData
@testable import MapViewer

@MainActor
final class WidgetDataSyncTests: XCTestCase {
    private var container: ModelContainer!
    private var testDefaults: UserDefaults!
    private var syncService: WidgetDataSyncService!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([SavedLocation.self, SearchHistoryItem.self, CustomPin.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try? ModelContainer(for: schema, configurations: [config])
        testDefaults = UserDefaults(suiteName: "WidgetDataSyncTestsSuite")
        testDefaults.removePersistentDomain(forName: "WidgetDataSyncTestsSuite")
        syncService = WidgetDataSyncService(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "WidgetDataSyncTestsSuite")
        testDefaults = nil
        syncService = nil
        container = nil
        super.tearDown()
    }
    
    func testInitialSnapshotIsEmpty() {
        let snapshot = syncService.readSnapshot()
        XCTAssertNil(snapshot.coordinate)
        XCTAssertTrue(snapshot.favoritePlaces.isEmpty)
    }
    
    func testSyncLocationUpdatesSnapshot() {
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        syncService.syncLocation(coordinate: coord, altitude: 52.0, heading: 180.0)
        
        let snapshot = syncService.readSnapshot()
        XCTAssertNotNil(snapshot.coordinate)
        XCTAssertEqual(snapshot.coordinate!.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(snapshot.coordinate!.longitude, -122.4194, accuracy: 0.0001)
        XCTAssertEqual(snapshot.coordinate?.altitudeMeters, 52.0)
        XCTAssertEqual(snapshot.coordinate?.headingDegrees, 180.0)
        XCTAssertTrue(snapshot.coordinate!.formattedDD.contains("37.7749° N"))
    }
    
    func testSyncFavoritesCalculatesDistances() {
        let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let place1 = SavedLocation(
            name: "Pier 39",
            notes: "Seals and shops",
            latitude: 37.8087,
            longitude: -122.4098,
            category: "Attraction",
            isFavorite: true
        )
        if let container = container {
            container.mainContext.insert(place1)
        }
        
        syncService.syncFavorites(places: [place1], userLocation: userCoord)
        
        let snapshot = syncService.readSnapshot()
        XCTAssertEqual(snapshot.favoritePlaces.count, 1)
        XCTAssertEqual(snapshot.favoritePlaces.first?.name, "Pier 39")
        XCTAssertNotNil(snapshot.favoritePlaces.first?.distanceMeters)
        XCTAssertGreaterThan(snapshot.favoritePlaces.first!.distanceMeters!, 1000.0)
        XCTAssertNotNil(snapshot.favoritePlaces.first?.formattedDistance)
    }
    
    func testPreviewSnapshotDataIntegrity() {
        let preview = WidgetSnapshotData.preview
        XCTAssertNotNil(preview.coordinate)
        XCTAssertEqual(preview.favoritePlaces.count, 3)
        XCTAssertEqual(preview.favoritePlaces.first?.name, "Ferry Building")
    }
}
