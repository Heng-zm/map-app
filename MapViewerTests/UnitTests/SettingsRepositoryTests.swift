//
//  SettingsRepositoryTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
@testable import MapViewer

final class SettingsRepositoryTests: XCTestCase {
    private var testDefaults: UserDefaults!
    private var repository: UserDefaultsSettingsRepository!
    
    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "MapViewerTestsDefaults")
        testDefaults.removePersistentDomain(forName: "MapViewerTestsDefaults")
        repository = UserDefaultsSettingsRepository(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "MapViewerTestsDefaults")
        testDefaults = nil
        repository = nil
        super.tearDown()
    }
    
    func testCoordinateFormatPersistence() {
        XCTAssertEqual(repository.coordinateFormat, .decimalDegrees) // default
        
        repository.coordinateFormat = .degreesMinutesSeconds
        XCTAssertEqual(repository.coordinateFormat, .degreesMinutesSeconds)
        
        // Re-instantiate repository to verify persistence across sessions
        let newRepo = UserDefaultsSettingsRepository(defaults: testDefaults)
        XCTAssertEqual(newRepo.coordinateFormat, .degreesMinutesSeconds)
    }
    
    func testUnitSystemPersistence() {
        XCTAssertEqual(repository.unitSystem, .metric)
        
        repository.unitSystem = .imperial
        XCTAssertEqual(repository.unitSystem, .imperial)
    }
    
    func testMapStylePersistence() {
        XCTAssertEqual(repository.mapStyle, .standard)
        
        repository.mapStyle = .satellite
        XCTAssertEqual(repository.mapStyle, .satellite)
    }
    
    func testElevationPersistence() {
        XCTAssertEqual(repository.mapElevation, .realistic)
        
        repository.mapElevation = .flat
        XCTAssertEqual(repository.mapElevation, .flat)
    }
    
    func testLayerTogglesPersistence() {
        repository.showsTraffic = true
        repository.showsBuildings = false
        repository.showsCompass = false
        repository.showsScale = false
        
        XCTAssertTrue(repository.showsTraffic)
        XCTAssertFalse(repository.showsBuildings)
        XCTAssertFalse(repository.showsCompass)
        XCTAssertFalse(repository.showsScale)
    }
}
