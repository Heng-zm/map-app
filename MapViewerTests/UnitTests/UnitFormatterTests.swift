//
//  UnitFormatterTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
@testable import MapViewer

final class UnitFormatterTests: XCTestCase {
    private var formatter: UnitFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = UnitFormatter()
    }
    
    override func tearDown() {
        formatter = nil
        super.tearDown()
    }
    
    func testMetricDistanceFormatting() {
        // Less than 1000m
        let shortDist = formatter.formatDistance(450.0, system: .metric)
        XCTAssertEqual(shortDist, "450 m")
        
        // Over 1000m
        let longDist = formatter.formatDistance(3250.0, system: .metric)
        XCTAssertEqual(longDist, "3.25 km")
    }
    
    func testImperialDistanceFormatting() {
        // Under 1000 ft (~304 meters)
        let shortDist = formatter.formatDistance(100.0, system: .imperial)
        XCTAssertTrue(shortDist.hasSuffix("ft"))
        
        // Miles
        let longDist = formatter.formatDistance(5000.0, system: .imperial)
        XCTAssertTrue(longDist.hasSuffix("mi"))
    }
    
    func testMetricAreaFormatting() {
        let smallArea = formatter.formatArea(250.0, system: .metric)
        XCTAssertEqual(smallArea, "250.0 m²")
        
        let largeArea = formatter.formatArea(5_000_000.0, system: .metric)
        XCTAssertTrue(largeArea.contains("km²"))
    }
    
    func testImperialAreaFormatting() {
        let smallArea = formatter.formatArea(100.0, system: .imperial)
        XCTAssertTrue(smallArea.contains("sq ft"))
        
        let mediumArea = formatter.formatArea(40_000.0, system: .imperial)
        XCTAssertTrue(mediumArea.contains("acres"))
    }
    
    func testDurationFormatting() {
        let underOneHour = formatter.formatDuration(1500) // 25 minutes
        XCTAssertEqual(underOneHour, "25 min")
        
        let overOneHour = formatter.formatDuration(4500) // 1 hour 15 min
        XCTAssertEqual(overOneHour, "1 hr 15 min")
    }
}
