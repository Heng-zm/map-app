//
//  DeepLinkHandlerTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

final class DeepLinkHandlerTests: XCTestCase {
    func testParseValidCoordinateURL() {
        let url = URL(string: "mapviewer://coordinate?lat=37.7749&lon=-122.4194")!
        let destination = DeepLinkHandler.parse(url: url)
        
        XCTAssertNotNil(destination)
        if case .coordinate(let coord) = destination {
            XCTAssertEqual(coord.latitude, 37.7749, accuracy: 0.0001)
            XCTAssertEqual(coord.longitude, -122.4194, accuracy: 0.0001)
        } else {
            XCTFail("Expected .coordinate destination")
        }
    }
    
    func testParseValidPlaceURL() {
        let url = URL(string: "mapviewer://place?lat=37.7955&lon=-122.3937&title=Ferry%20Building")!
        let destination = DeepLinkHandler.parse(url: url)
        
        XCTAssertNotNil(destination)
        if case .place(let coord, let title) = destination {
            XCTAssertEqual(coord.latitude, 37.7955, accuracy: 0.0001)
            XCTAssertEqual(coord.longitude, -122.3937, accuracy: 0.0001)
            XCTAssertEqual(title, "Ferry Building")
        } else {
            XCTFail("Expected .place destination")
        }
    }
    
    func testParseQuickActions() {
        let searchURL = URL(string: "mapviewer://search?q=coffee")!
        if case .search(let q) = DeepLinkHandler.parse(url: searchURL) {
            XCTAssertEqual(q, "coffee")
        } else {
            XCTFail("Expected .search destination")
        }
        
        let measureURL = URL(string: "mapviewer://measure")!
        XCTAssertEqual(DeepLinkHandler.parse(url: measureURL), .measure)
        
        let locateURL = URL(string: "mapviewer://locate")!
        XCTAssertEqual(DeepLinkHandler.parse(url: locateURL), .locate)
    }
    
    func testParseInvalidSchemeReturnsNil() {
        let url = URL(string: "https://maps.apple.com/?ll=37.7749,-122.4194")!
        XCTAssertNil(DeepLinkHandler.parse(url: url))
    }
    
    func testParseMalformedCoordinateReturnsNil() {
        let invalidLat = URL(string: "mapviewer://coordinate?lat=195.0&lon=-122.4194")!
        XCTAssertNil(DeepLinkHandler.parse(url: invalidLat))
        
        let missingParams = URL(string: "mapviewer://coordinate?foo=bar")!
        XCTAssertNil(DeepLinkHandler.parse(url: missingParams))
    }
    
    func testURLGenerationHelpers() {
        let coordURL = DeepLinkHandler.coordinateURL(latitude: 37.7749, longitude: -122.4194)
        XCTAssertNotNil(coordURL)
        XCTAssertEqual(DeepLinkHandler.parse(url: coordURL!), .coordinate(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)))
        
        let placeURL = DeepLinkHandler.placeURL(latitude: 37.7749, longitude: -122.4194, title: "Market St")
        XCTAssertNotNil(placeURL)
        XCTAssertEqual(DeepLinkHandler.parse(url: placeURL!), .place(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), title: "Market St"))
    }
}
