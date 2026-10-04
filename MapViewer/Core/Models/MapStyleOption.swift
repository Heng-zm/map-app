//
//  MapStyleOption.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI
import MapKit

/// Visual map styles supported by Map Viewer.
public enum MapStyleOption: String, CaseIterable, Identifiable, Codable, Sendable {
    case standard = "standard"
    case satellite = "satellite"
    case hybrid = "hybrid"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .standard:
            return "Standard"
        case .satellite:
            return "Satellite"
        case .hybrid:
            return "Hybrid"
        }
    }
    
    public var iconName: String {
        switch self {
        case .standard:
            return "map"
        case .satellite:
            return "globe.americas.fill"
        case .hybrid:
            return "square.stack.3d.down.right.fill"
        }
    }
    
    /// Maps to modern SwiftUI MapStyle configuration.
    public func toMapStyle(elevation: MapElevation = .realistic, showsTraffic: Bool = false) -> MapStyle {
        switch self {
        case .standard:
            return .standard(
                elevation: elevation == .realistic ? .realistic : .flat,
                pointsOfInterest: .all,
                showsTraffic: showsTraffic
            )
        case .satellite:
            return .imagery(
                elevation: elevation == .realistic ? .realistic : .flat
            )
        case .hybrid:
            return .hybrid(
                elevation: elevation == .realistic ? .realistic : .flat,
                pointsOfInterest: .all,
                showsTraffic: showsTraffic
            )
        }
    }
}

/// Map elevation preference (2D flat vs 3D realistic terrain & buildings).
public enum MapElevation: String, CaseIterable, Identifiable, Codable, Sendable {
    case flat = "flat"
    case realistic = "realistic"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .flat:
            return "2D (Flat)"
        case .realistic:
            return "3D (Realistic)"
        }
    }
}
