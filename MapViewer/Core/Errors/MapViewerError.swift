//
//  MapViewerError.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

/// Centralized error domain for Map Viewer.
public enum MapViewerError: LocalizedError, Equatable, Sendable {
    case locationPermissionDenied
    case locationPermissionRestricted
    case locationServicesDisabled
    case locationUnavailable
    case searchFailed(String)
    case emptySearchQuery
    case noSearchResults
    case geocodingFailed(String)
    case routeNotFound
    case invalidRouteCoordinates
    case unsupportedTransportMode
    case measurementRequiresMorePoints
    case networkUnavailable
    case persistenceFailed(String)
    case itemNotFound
    case operationCancelled
    
    public var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "Location Permission Denied"
        case .locationPermissionRestricted:
            return "Location Access Restricted"
        case .locationServicesDisabled:
            return "Location Services Disabled"
        case .locationUnavailable:
            return "Location Unavailable"
        case .searchFailed(let reason):
            return "Search Failed: \(reason)"
        case .emptySearchQuery:
            return "Please enter a search query."
        case .noSearchResults:
            return "No matching places found."
        case .geocodingFailed(let reason):
            return "Address Lookup Failed: \(reason)"
        case .routeNotFound:
            return "No Route Found"
        case .invalidRouteCoordinates:
            return "Invalid start or destination coordinates."
        case .unsupportedTransportMode:
            return "The selected transportation mode is not available for this route."
        case .measurementRequiresMorePoints:
            return "At least two points are required to measure distance."
        case .networkUnavailable:
            return "Network connection appears offline."
        case .persistenceFailed(let reason):
            return "Storage Error: \(reason)"
        case .itemNotFound:
            return "The requested item was not found."
        case .operationCancelled:
            return "The operation was cancelled."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .locationPermissionDenied:
            return "Please enable Location Access in your device's Settings > Privacy > Location Services > Map Viewer."
        case .locationPermissionRestricted:
            return "Location access is restricted by device parental controls or system configuration."
        case .locationServicesDisabled:
            return "Turn on Location Services in Settings > Privacy & Security to allow Map Viewer to determine your position."
        case .locationUnavailable:
            return "Ensure you have a clear GPS signal or internet connectivity."
        case .searchFailed:
            return "Check your internet connection and try modifying your search keywords."
        case .emptySearchQuery:
            return "Type a landmark, city, business name, or address."
        case .noSearchResults:
            return "Try searching with different keywords, check the spelling, or zoom out the map."
        case .geocodingFailed:
            return "Verify the coordinate or address, or check your internet connection."
        case .routeNotFound:
            return "Directions may not be available between these locations for the selected transport type. Try selecting Driving or Walking."
        case .invalidRouteCoordinates:
            return "Verify that valid start and destination locations have been selected on the map."
        case .unsupportedTransportMode:
            return "Try switching to Driving or Walking."
        case .measurementRequiresMorePoints:
            return "Tap on the map to add more measurement waypoints."
        case .networkUnavailable:
            return "Please verify your Wi-Fi or cellular data connection."
        case .persistenceFailed:
            return "Your device may be low on storage space."
        case .itemNotFound:
            return "The item may have already been removed."
        case .operationCancelled:
            return nil
        }
    }
    
    public var failureReason: String? {
        return errorDescription
    }
}
