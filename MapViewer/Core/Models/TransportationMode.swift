//
//  TransportationMode.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import MapKit

/// Supported transportation modes for routing calculation.
public enum TransportationMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case automobile = "automobile"
    case walking = "walking"
    case transit = "transit"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .automobile:
            return "Driving"
        case .walking:
            return "Walking"
        case .transit:
            return "Transit"
        }
    }
    
    public var iconName: String {
        switch self {
        case .automobile:
            return "car.fill"
        case .walking:
            return "figure.walk"
        case .transit:
            return "tram.fill"
        }
    }
    
    public var mkDirectionsTransportType: MKDirectionsTransportType {
        switch self {
        case .automobile:
            return .automobile
        case .walking:
            return .walking
        case .transit:
            return .transit
        }
    }
}
