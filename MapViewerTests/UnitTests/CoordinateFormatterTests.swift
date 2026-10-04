//
//  CoordinateFormatterTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

final class CoordinateFormatterTests: XCTestCase {
    private var formatter: CoordinateFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CoordinateFormatter()
    }
    
    override func tearDown() {
        formatter = nil
        super.tearDown()
    }
    
    func testFormatDecimalDegreesPositive() {
        let coord = CLLocationCoordinate2D(latitude: 37.774929, longitude: 122.419416)
        let formatted = formatter.formatDecimalDegrees(coord, precision: 4)
        XCTAssertEqual(formatted, "37.7749° N, 122.4194° E")
    }
    
    func testFormatDecimalDegreesNegative() {
        let coord = CLLocationCoordinate2D(latitude: -33.8688, longitude: -151.2093)
        let formatted = formatter.formatDecimalDegrees(coord, precision: 4)
        XCTAssertEqual(formatted, "33.8688° S, 151.2093° W")
    }
    
    func testFormatDMSConversion() {
        // 37.7749° -> 37° 46' 29.64" N
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let formatted = formatter.formatDMS(coord)
        
        XCTAssertTrue(formatted.contains("37° 46'"))
        XCTAssertTrue(formatted.contains("N"))
        XCTAssertTrue(formatted.contains("122° 25'"))
        XCTAssertTrue(formatted.contains("W"))
    }
    
    func testRawDecimalFormatting() {
        let coord = CLLocationCoordinate2D(latitude: 37.774900, longitude: -122.419400)
        let raw = formatter.formatRawDecimal(coord, precision: 4)
        XCTAssertEqual(raw, "37.7749, -122.4194")
    }
    
    func testInvalidCoordinateReturnsFallback() {
        let invalid = CLLocationCoordinate2D(latitude: 95.0, longitude: 200.0)
        let formatted = formatter.formatDecimalDegrees(invalid)
        XCTAssertEqual(formatted, "Invalid Coordinate")
    }
    
    func testAppleMapsURLGeneration() {
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let url = formatter.appleMapsURL(for: coord, name: "San Francisco")
        
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("maps.apple.com"))
        XCTAssertTrue(url!.absoluteString.contains("37.7749"))
        XCTAssertTrue(url!.absoluteString.contains("San%20Francisco") || url!.absoluteString.contains("San+Francisco"))
    }
}
