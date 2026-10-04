//
//  UnitFormatter.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

/// Formats distance, area, and duration into localized metric and imperial representations.
public final class UnitFormatter: Sendable {
    public static let shared = UnitFormatter()
    
    public init() {}
    
    // MARK: - Distance Formatting
    
    /// Formats distance in meters according to UnitSystem preference.
    public func formatDistance(_ meters: Double, system: UnitSystem) -> String {
        guard meters >= 0 else { return "0 m" }
        let posixLocale = Locale(identifier: "en_US_POSIX")
        
        switch system {
        case .metric:
            if meters < 1000 {
                return String(format: "%.0f m", locale: posixLocale, meters)
            } else {
                return String(format: "%.2f km", locale: posixLocale, meters / 1000.0)
            }
        case .imperial:
            let feet = meters * 3.28084
            if feet < 1000 {
                return String(format: "%.0f ft", locale: posixLocale, feet)
            } else {
                let miles = meters * 0.000621371
                return String(format: "%.2f mi", locale: posixLocale, miles)
            }
        }
    }
    
    // MARK: - Area Formatting
    
    /// Formats area in square meters according to UnitSystem preference.
    public func formatArea(_ squareMeters: Double, system: UnitSystem) -> String {
        guard squareMeters >= 0 else { return "0 m²" }
        let posixLocale = Locale(identifier: "en_US_POSIX")
        
        switch system {
        case .metric:
            if squareMeters < 10_000 {
                return String(format: "%.1f m²", locale: posixLocale, squareMeters)
            } else {
                let squareKm = squareMeters / 1_000_000.0
                if squareKm < 0.01 {
                    let hectares = squareMeters / 10_000.0
                    return String(format: "%.2f ha", locale: posixLocale, hectares)
                }
                return String(format: "%.3f km²", locale: posixLocale, squareKm)
            }
        case .imperial:
            let squareFeet = squareMeters * 10.7639
            if squareFeet < 43_560 { // Less than 1 acre
                return String(format: "%.0f sq ft", locale: posixLocale, squareFeet)
            } else {
                let acres = squareMeters * 0.000247105
                if acres < 640 { // Less than 1 square mile
                    return String(format: "%.2f acres", locale: posixLocale, acres)
                } else {
                    let squareMiles = squareMeters * 3.861e-7
                    return String(format: "%.2f sq mi", locale: posixLocale, squareMiles)
                }
            }
        }
    }
    
    // MARK: - Duration Formatting
    
    /// Formats travel duration in seconds into human-readable hours and minutes.
    public func formatDuration(_ seconds: TimeInterval) -> String {
        guard seconds > 0 else { return "0 min" }
        
        let totalMinutes = Int(round(seconds / 60.0))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours) hr \(minutes) min"
            } else {
                return "\(hours) hr"
            }
        } else {
            return "\(max(1, minutes)) min"
        }
    }
}
