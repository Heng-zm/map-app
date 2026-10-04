//
//  CoordinateFormatter.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Utility for converting CLLocationCoordinate2D into Decimal Degrees (DD) and Degrees Minutes Seconds (DMS).
public final class CoordinateFormatter: Sendable {
    public static let shared = CoordinateFormatter()
    
    public init() {}
    
    /// Formats a coordinate using the specified CoordinateFormat enum.
    public func format(_ coordinate: CLLocationCoordinate2D, format: CoordinateFormat) -> String {
        switch format {
        case .decimalDegrees:
            return formatDecimalDegrees(coordinate)
        case .degreesMinutesSeconds:
            return formatDMS(coordinate)
        }
    }
    
    /// Formats as Decimal Degrees: e.g. "37.774929° N, 122.419416° W"
    public func formatDecimalDegrees(_ coordinate: CLLocationCoordinate2D, precision: Int = 6) -> String {
        guard coordinate.isValidCoordinate else { return "Invalid Coordinate" }
        
        let latCardinal = coordinate.latitude >= 0 ? "N" : "S"
        let lonCardinal = coordinate.longitude >= 0 ? "E" : "W"
        
        let absLat = abs(coordinate.latitude)
        let absLon = abs(coordinate.longitude)
        
        let posixLocale = Locale(identifier: "en_US_POSIX")
        let latStr = String(format: locale: posixLocale, "%.\(precision)f° %@", absLat, latCardinal)
        let lonStr = String(format: locale: posixLocale, "%.\(precision)f° %@", absLon, lonCardinal)
        
        return "\(latStr), \(lonStr)"
    }
    
    /// Formats as raw signed Decimal Degrees: e.g. "37.774929, -122.419416"
    public func formatRawDecimal(_ coordinate: CLLocationCoordinate2D, precision: Int = 6) -> String {
        guard coordinate.isValidCoordinate else { return "Invalid Coordinate" }
        let posixLocale = Locale(identifier: "en_US_POSIX")
        return String(format: locale: posixLocale, "%.\(precision)f, %.\(precision)f", coordinate.latitude, coordinate.longitude)
    }
    
    /// Formats as Degrees Minutes Seconds: e.g. "37° 46' 29.74\" N, 122° 25' 09.90\" W"
    public func formatDMS(_ coordinate: CLLocationCoordinate2D) -> String {
        guard coordinate.isValidCoordinate else { return "Invalid Coordinate" }
        
        let latDMS = formatSingleDMS(degrees: coordinate.latitude, positiveCardinal: "N", negativeCardinal: "S")
        let lonDMS = formatSingleDMS(degrees: coordinate.longitude, positiveCardinal: "E", negativeCardinal: "W")
        
        return "\(latDMS), \(lonDMS)"
    }
    
    /// Internal helper to calculate (Degrees, Minutes, Seconds) for a single value.
    public func formatSingleDMS(degrees: Double, positiveCardinal: String, negativeCardinal: String) -> String {
        let cardinal = degrees >= 0 ? positiveCardinal : negativeCardinal
        let totalVal = abs(degrees)
        
        let d = Int(totalVal)
        let minutesNotTruncated = (totalVal - Double(d)) * 60.0
        let m = Int(minutesNotTruncated)
        let s = (minutesNotTruncated - Double(m)) * 60.0
        
        let posixLocale = Locale(identifier: "en_US_POSIX")
        return String(format: locale: posixLocale, "%d° %02d' %05.2f\" %@", d, m, s, cardinal)
    }
    
    /// Generates an Apple Maps web/deep link URL for a coordinate and optional name.
    public func appleMapsURL(for coordinate: CLLocationCoordinate2D, name: String? = nil) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        var queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)")
        ]
        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: name))
        }
        components?.queryItems = queryItems
        return components?.url
    }
}
