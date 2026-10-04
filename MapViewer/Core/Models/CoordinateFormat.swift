//
//  CoordinateFormat.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

/// Supported coordinate representation formats in Map Viewer.
public enum CoordinateFormat: String, CaseIterable, Identifiable, Codable, Sendable {
    case decimalDegrees = "DD"
    case degreesMinutesSeconds = "DMS"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .decimalDegrees:
            return "Decimal Degrees (DD)"
        case .degreesMinutesSeconds:
            return "Degrees Minutes Seconds (DMS)"
        }
    }
    
    public var exampleString: String {
        switch self {
        case .decimalDegrees:
            return "37.774929° N, 122.419416° W"
        case .degreesMinutesSeconds:
            return "37° 46' 29.74\" N, 122° 25' 09.90\" W"
        }
    }
}
