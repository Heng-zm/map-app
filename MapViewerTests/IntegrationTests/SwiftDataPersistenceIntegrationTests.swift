//
//  SwiftDataPersistenceIntegrationTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import SwiftData
import CoreLocation
@testable import MapViewer

@MainActor
final class SwiftDataPersistenceIntegrationTests: XCTestCase {
    private var container: ModelContainer!
    private var locationRepo: SwiftDataSavedLocationRepository!
    private var historyRepo: SwiftDataSearchHistoryRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let schema = Schema([
            SavedLocation.self,
            SearchHistoryItem.self,
            CustomPin.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        
        locationRepo = SwiftDataSavedLocationRepository(modelContainer: container)
        historyRepo = SwiftDataSearchHistoryRepository(modelContainer: container)
    }
    
    override func tearDown() async throws {
        locationRepo = nil
        historyRepo = nil
        container = nil
        try await super.tearDown()
    }
    
    func testSavedLocationCRUDWorkflow() throws {
        // 1. Initial should be empty
        var all = try locationRepo.fetchAll()
        XCTAssertTrue(all.isEmpty)
        
        // 2. Save location
        let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let sf = SavedLocation(
            name: "San Francisco City Hall",
            notes: "Beautiful dome architecture",
            latitude: sfCoord.latitude,
            longitude: sfCoord.longitude,
            address: "1 Dr Carlton B Goodlett Pl, San Francisco, CA",
            category: "Landmark",
            isFavorite: false
        )
        try locationRepo.save(sf)
        
        all = try locationRepo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.name, "San Francisco City Hall")
        XCTAssertFalse(all.first!.isFavorite)
        
        // 3. Toggle favorite
        try locationRepo.toggleFavorite(sf)
        let favorites = try locationRepo.fetchFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.name, "San Francisco City Hall")
        XCTAssertTrue(favorites.first!.isFavorite)
        
        // 4. Update
        sf.name = "SF City Hall (Updated)"
        try locationRepo.update(sf)
        all = try locationRepo.fetchAll()
        XCTAssertEqual(all.first?.name, "SF City Hall (Updated)")
        
        // 5. Delete
        try locationRepo.delete(sf)
        all = try locationRepo.fetchAll()
        XCTAssertTrue(all.isEmpty)
    }
    
    func testCustomPinPersistence() throws {
        let pin = CustomPin(
            title: "Observation Deck",
            subtitle: "Twin Peaks",
            notes: "Great view of the bay",
            latitude: 37.7544,
            longitude: -122.4477,
            colorHex: "#007AFF",
            isFavorite: true
        )
        try locationRepo.savePin(pin)
        
        let pins = try locationRepo.fetchAllPins()
        XCTAssertEqual(pins.count, 1)
        XCTAssertEqual(pins.first?.title, "Observation Deck")
        XCTAssertEqual(pins.first?.colorHex, "#007AFF")
        
        // Convert to domain struct
        let domainPin = pins.first!.toLocationPin()
        XCTAssertEqual(domainPin.title, "Observation Deck")
        XCTAssertEqual(domainPin.coordinate.latitude, 37.7544, accuracy: 0.0001)
        
        // Delete pin
        try locationRepo.deletePin(pin)
        let emptyPins = try locationRepo.fetchAllPins()
        XCTAssertTrue(emptyPins.isEmpty)
    }
    
    func testSearchHistoryDeduplicationAndClearing() throws {
        let coord = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        
        // Add query
        try historyRepo.add(query: "Apple Park", title: "Apple Park", subtitle: "Cupertino", coordinate: coord)
        var recent = try historyRepo.fetchRecent(limit: 10)
        XCTAssertEqual(recent.count, 1)
        
        // Add duplicate query with different casing
        try historyRepo.add(query: "apple park", title: "Apple Park Visitor Center", subtitle: "Cupertino, CA", coordinate: coord)
        recent = try historyRepo.fetchRecent(limit: 10)
        XCTAssertEqual(recent.count, 1, "Duplicate query should be deduplicated")
        XCTAssertEqual(recent.first?.title, "Apple Park Visitor Center")
        
        // Clear all
        try historyRepo.clearAll()
        recent = try historyRepo.fetchRecent(limit: 10)
        XCTAssertTrue(recent.isEmpty)
    }
}
