//
//  UnitSystem.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

/// Measurement unit system preference.
public enum UnitSystem: String, CaseIterable, Identifiable, Codable, Sendable {
    case metric = "metric"
    case imperial = "imperial"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .metric:
            return "Metric (m, km, km²)"
        case .imperial:
            return "Imperial (ft, mi, acres)"
        }
    }
    
    public var shortName: String {
        switch self {
        case .metric:
            return "Metric"
        case .imperial:
            return "Imperial"
        }
    }
}
