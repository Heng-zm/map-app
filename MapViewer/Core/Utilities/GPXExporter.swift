//
//  GPXExporter.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Formatter and exporter for converting recorded GPS tracks into standard GPX 1.1 XML.
public struct GPXExporter: Sendable {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    /// Converts a RecordedTrack into a valid GPX 1.1 XML string.
    public static func export(track: RecordedTrack) -> String {
        let posix = Locale(identifier: "en_US_POSIX")
        let creationDate = iso8601Formatter.string(from: track.startTime)
        let escapedTitle = escapeXML(track.title)
        let escapedNotes = escapeXML(track.notes)
        
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MapViewer iOS" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
          <metadata>
            <name>\(escapedTitle)</name>
            <time>\(creationDate)</time>
        """
        
        if !escapedNotes.isEmpty {
            xml += "\n    <desc>\(escapedNotes)</desc>"
        }
        
        xml += """
        
          </metadata>
          <trk>
            <name>\(escapedTitle)</name>
            <type>\(track.activityType.rawValue)</type>
            <trkseg>
        """
        
        for pt in track.points {
            let latStr = String(format: locale: posix, "%.6f", pt.latitude)
            let lonStr = String(format: locale: posix, "%.6f", pt.longitude)
            let timeStr = iso8601Formatter.string(from: pt.timestamp)
            
            xml += "\n      <trkpt lat=\"\(latStr)\" lon=\"\(lonStr)\">"
            if let alt = pt.altitude {
                xml += "\n        <ele>\(String(format: locale: posix, "%.1f", alt))</ele>"
            }
            xml += "\n        <time>\(timeStr)</time>"
            if let speed = pt.speed, speed >= 0 {
                xml += "\n        <speed>\(String(format: locale: posix, "%.2f", speed))</speed>"
            }
            xml += "\n      </trkpt>"
        }
        
        xml += """
        
            </trkseg>
          </trk>
        </gpx>
        """
        
        return xml
    }
    
    /// Writes track to a temporary file URL and returns it (for ShareLink or export).
    public static func createExportFile(for track: RecordedTrack) throws -> URL {
        let gpxString = export(track: track)
        let safeTitle = track.title
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        let filename = "\(safeTitle.isEmpty ? "Track" : safeTitle).gpx"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try gpxString.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
    
    private static func escapeXML(_ str: String) -> String {
        str.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
