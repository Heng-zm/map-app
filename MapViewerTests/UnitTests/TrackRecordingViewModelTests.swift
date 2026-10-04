//
//  TrackRecordingViewModelTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

@MainActor
final class TrackRecordingViewModelTests: XCTestCase {
    private var viewModel: TrackRecordingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TrackRecordingViewModel()
    }
    
    override func tearDown() {
        viewModel.discardRecording()
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.distanceMeters, 0.0)
        XCTAssertEqual(viewModel.trackPoints.count, 0)
        XCTAssertNil(viewModel.completedTrack)
    }
    
    func testStartAndProcessLocations() {
        viewModel.startRecording(activity: .cycling)
        XCTAssertTrue(viewModel.isRecording)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.selectedActivity, .cycling)
        
        let loc1 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0.0,
            speed: 4.5,
            timestamp: Date()
        )
        
        let loc2 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7760, longitude: -122.4194),
            altitude: 15.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0.0,
            speed: 6.0,
            timestamp: Date().addingTimeInterval(10)
        )
        
        viewModel.processLocationUpdate(loc1)
        XCTAssertEqual(viewModel.trackPoints.count, 1)
        XCTAssertEqual(viewModel.distanceMeters, 0.0) // first point starts tracking
        
        viewModel.processLocationUpdate(loc2)
        XCTAssertEqual(viewModel.trackPoints.count, 2)
        XCTAssertGreaterThan(viewModel.distanceMeters, 100.0) // ~122 meters
        XCTAssertEqual(viewModel.elevationGainMeters, 5.0, accuracy: 0.1)
        XCTAssertEqual(viewModel.maxSpeedMps, 6.0)
    }
    
    func testRejectsInaccurateLocations() {
        viewModel.startRecording()
        
        let badLoc = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 10.0,
            horizontalAccuracy: 80.0, // Too inaccurate (>35m)
            verticalAccuracy: 10.0,
            timestamp: Date()
        )
        
        viewModel.processLocationUpdate(badLoc)
        XCTAssertEqual(viewModel.trackPoints.count, 0)
    }
    
    func testPauseAndResume() {
        viewModel.startRecording()
        viewModel.pauseRecording()
        XCTAssertTrue(viewModel.isPaused)
        
        let loc = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            timestamp: Date()
        )
        
        // Location should be ignored while paused
        viewModel.processLocationUpdate(loc)
        XCTAssertEqual(viewModel.trackPoints.count, 0)
        
        viewModel.resumeRecording()
        XCTAssertFalse(viewModel.isPaused)
        viewModel.processLocationUpdate(loc)
        XCTAssertEqual(viewModel.trackPoints.count, 1)
    }
    
    func testStopRecordingProducesValidTrack() {
        viewModel.startRecording(activity: .running)
        
        let loc1 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0.0,
            speed: 3.0,
            timestamp: Date()
        )
        let loc2 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7759, longitude: -122.4194),
            altitude: 12.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0.0,
            speed: 3.5,
            timestamp: Date().addingTimeInterval(5)
        )
        
        viewModel.processLocationUpdate(loc1)
        viewModel.processLocationUpdate(loc2)
        
        let track = viewModel.stopRecording()
        XCTAssertNotNil(track)
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertEqual(track?.activityType, .running)
        XCTAssertEqual(track?.points.count, 2)
        XCTAssertGreaterThan(track!.distanceMeters, 50.0)
        XCTAssertTrue(viewModel.isDetailSheetPresented)
    }
}
