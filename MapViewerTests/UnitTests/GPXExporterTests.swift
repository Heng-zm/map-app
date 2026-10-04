//
//  GPXExporterTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import CoreLocation
@testable import MapViewer

final class GPXExporterTests: XCTestCase {
    func testExportBasicTrackToGPX() {
        let p1 = TrackPoint(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 45.0,
            speed: 1.5,
            timestamp: Date(timeIntervalSince1970: 1700000000)
        )
        let p2 = TrackPoint(
            latitude: 37.7759,
            longitude: -122.4184,
            altitude: 52.0,
            speed: 2.1,
            timestamp: Date(timeIntervalSince1970: 1700000060)
        )
        
        let track = RecordedTrack(
            title: "Twin Peaks Hike",
            notes: "Sunny afternoon trek",
            activityType: .hiking,
            points: [p1, p2],
            startTime: Date(timeIntervalSince1970: 1700000000),
            endTime: Date(timeIntervalSince1970: 1700000060),
            distanceMeters: 145.0,
            durationSeconds: 60.0,
            elevationGainMeters: 7.0,
            maxSpeedMps: 2.1
        )
        
        let xml = GPXExporter.export(track: track)
        
        XCTAssertTrue(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        XCTAssertTrue(xml.contains("<gpx version=\"1.1\""))
        XCTAssertTrue(xml.contains("<name>Twin Peaks Hike</name>"))
        XCTAssertTrue(xml.contains("<desc>Sunny afternoon trek</desc>"))
        XCTAssertTrue(xml.contains("<type>Hiking</type>"))
        XCTAssertTrue(xml.contains("<trkpt lat=\"37.774900\" lon=\"-122.419400\">"))
        XCTAssertTrue(xml.contains("<ele>45.0</ele>"))
        XCTAssertTrue(xml.contains("<trkpt lat=\"37.775900\" lon=\"-122.418400\">"))
        XCTAssertTrue(xml.contains("<ele>52.0</ele>"))
        XCTAssertTrue(xml.contains("</trkseg>"))
        XCTAssertTrue(xml.contains("</trk>"))
        XCTAssertTrue(xml.contains("</gpx>"))
    }
    
    func testExportEscapesSpecialXMLCharacters() {
        let track = RecordedTrack(
            title: "Fish & Chips <Route> \"Run\"",
            notes: "Notes with <tags> & 'quotes'",
            activityType: .running,
            points: []
        )
        
        let xml = GPXExporter.export(track: track)
        
        XCTAssertTrue(xml.contains("Fish &amp; Chips &lt;Route&gt; &quot;Run&quot;"))
        XCTAssertTrue(xml.contains("Notes with &lt;tags&gt; &amp; &apos;quotes&apos;"))
    }
    
    func testCreateExportFileWritesValidGPX() throws {
        let p1 = TrackPoint(latitude: 37.7749, longitude: -122.4194)
        let track = RecordedTrack(title: "Test Track Export", points: [p1])
        
        let fileURL = try GPXExporter.createExportFile(for: track)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("<gpx version=\"1.1\""))
        XCTAssertTrue(contents.contains("Test Track Export"))
        
        try? FileManager.default.removeItem(at: fileURL)
    }
}
