//
//  GeodesicMathTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

final class GeodesicMathTests: XCTestCase {
    private var calculator: GeodesicCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = GeodesicCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    func testHaversineDistanceBetweenSanFranciscoAndNewYork() {
        // San Francisco (37.7749, -122.4194) to New York JFK (40.6413, -73.7781)
        // Known great circle distance is approx 4,130 - 4,150 km.
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let ny = CLLocationCoordinate2D(latitude: 40.6413, longitude: -73.7781)
        
        let distanceMeters = calculator.haversineDistance(from: sf, to: ny)
        let distanceKm = distanceMeters / 1000.0
        
        XCTAssertGreaterThan(distanceKm, 4100.0)
        XCTAssertLessThan(distanceKm, 4200.0)
    }
    
    func testHaversineDistanceIdenticalPoints() {
        let p = CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)
        let distance = calculator.haversineDistance(from: p, to: p)
        XCTAssertEqual(distance, 0.0, accuracy: 0.001)
    }
    
    func testPathDistanceSummation() {
        // A -> B -> C
        let p1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let p2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 1.0)
        let p3 = CLLocationCoordinate2D(latitude: 0.0, longitude: 2.0)
        
        let d1 = calculator.haversineDistance(from: p1, to: p2)
        let d2 = calculator.haversineDistance(from: p2, to: p3)
        let total = calculator.pathDistance(coordinates: [p1, p2, p3])
        
        XCTAssertEqual(total, d1 + d2, accuracy: 0.01)
    }
    
    func testPolygonPerimeter() {
        let p1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let p2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 1.0)
        let p3 = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        
        let pathDist = calculator.pathDistance(coordinates: [p1, p2, p3])
        let closing = calculator.haversineDistance(from: p3, to: p1)
        let perimeter = calculator.polygonPerimeter(coordinates: [p1, p2, p3])
        
        XCTAssertEqual(perimeter, pathDist + closing, accuracy: 0.01)
    }
    
    func testPolygonAreaChamberlainDuquette() {
        // 1-degree by 1-degree square at equator: lat 0..1, lon 0..1
        // 1 degree latitude ~ 111,195 m.
        // 1 degree longitude at equator ~ 111,195 m.
        // Expected planar area ~ 111195 * 111195 ~ 1.236e10 m²
        let p1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let p2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 1.0)
        let p3 = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        let p4 = CLLocationCoordinate2D(latitude: 1.0, longitude: 0.0)
        
        let area = calculator.polygonArea(coordinates: [p1, p2, p3, p4])
        
        XCTAssertGreaterThan(area, 1.20e10)
        XCTAssertLessThan(area, 1.25e10)
    }
    
    func testDegeneratePolygonAreaReturnsZero() {
        let p1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let p2 = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        
        let area = calculator.polygonArea(coordinates: [p1, p2])
        XCTAssertEqual(area, 0.0)
    }
}
