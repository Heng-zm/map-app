//
//  RouteViewModelTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

@MainActor
final class RouteViewModelTests: XCTestCase {
    private var locationService: LocationService!
    private var routingService: RoutingService!
    private var viewModel: RouteViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        locationService = LocationService()
        routingService = RoutingService()
        viewModel = RouteViewModel(
            routingService: routingService,
            locationService: locationService
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        routingService = nil
        locationService = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.transportMode, .automobile)
        XCTAssertTrue(viewModel.routes.isEmpty)
        XCTAssertNil(viewModel.activeRoute)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSetEndpointsAndSwap() {
        let p1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let p2 = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        
        viewModel.setStart(coordinate: p1, name: "San Francisco")
        viewModel.setDestination(coordinate: p2, name: "Apple Park")
        
        XCTAssertEqual(viewModel.startName, "San Francisco")
        XCTAssertEqual(viewModel.destinationName, "Apple Park")
        XCTAssertEqual(viewModel.startCoordinate?.latitude, p1.latitude)
        XCTAssertEqual(viewModel.destinationCoordinate?.latitude, p2.latitude)
        
        // Swap
        viewModel.swapEndpoints()
        XCTAssertEqual(viewModel.startName, "Apple Park")
        XCTAssertEqual(viewModel.destinationName, "San Francisco")
        XCTAssertEqual(viewModel.startCoordinate?.latitude, p2.latitude)
        XCTAssertEqual(viewModel.destinationCoordinate?.latitude, p1.latitude)
    }
    
    func testChangeTransportMode() {
        viewModel.setTransportMode(.walking)
        XCTAssertEqual(viewModel.transportMode, .walking)
        
        viewModel.setTransportMode(.transit)
        XCTAssertEqual(viewModel.transportMode, .transit)
    }
    
    func testClearRouteResetsState() {
        let p2 = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        viewModel.setDestination(coordinate: p2, name: "Apple Park")
        
        viewModel.clear()
        XCTAssertNil(viewModel.destinationCoordinate)
        XCTAssertEqual(viewModel.destinationName, "")
        XCTAssertTrue(viewModel.routes.isEmpty)
        XCTAssertNil(viewModel.activeRoute)
    }
}
