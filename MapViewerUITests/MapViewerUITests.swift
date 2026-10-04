//
//  MapViewerUITests.swift
//  MapViewerUITests
//
//  Created for Map Viewer Production App.
//

import XCTest

final class MapViewerUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunchShowsMapAndControls() throws {
        // Verify search trigger is visible
        let searchButton = app.buttons["Search places and addresses"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5.0))
        
        // Verify settings button is visible
        let settingsButton = app.buttons["Open Settings"]
        XCTAssertTrue(settingsButton.exists)
        
        // Verify floating controls
        let locateMe = app.buttons["Locate Me"]
        XCTAssertTrue(locateMe.exists)
        
        let zoomIn = app.buttons["Zoom In"]
        XCTAssertTrue(zoomIn.exists)
        
        let zoomOut = app.buttons["Zoom Out"]
        XCTAssertTrue(zoomOut.exists)
    }
    
    func testOpenSearchSheet() throws {
        let searchButton = app.buttons["Search places and addresses"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5.0))
        searchButton.tap()
        
        // Verify search sheet navigation title
        let searchNavTitle = app.navigationBars["Search"]
        XCTAssertTrue(searchNavTitle.waitForExistence(timeout: 3.0))
        
        // Close search sheet
        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.exists)
        closeButton.tap()
    }
    
    func testOpenSettingsSheet() throws {
        let settingsButton = app.buttons["Open Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0))
        settingsButton.tap()
        
        let settingsNav = app.navigationBars["Settings"]
        XCTAssertTrue(settingsNav.waitForExistence(timeout: 3.0))
        
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
    }
    
    func testOpenMapStylePicker() throws {
        let styleButton = app.buttons["Map Style"]
        XCTAssertTrue(styleButton.waitForExistence(timeout: 5.0))
        styleButton.tap()
        
        let configTitle = app.navigationBars["Map Configuration"]
        XCTAssertTrue(configTitle.waitForExistence(timeout: 3.0))
        
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
    }
}
