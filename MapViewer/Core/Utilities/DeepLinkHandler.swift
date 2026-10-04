//
//  DeepLinkHandler.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Supported deep link destinations for widgets and external navigation.
public enum DeepLinkDestination: Equatable, Sendable {
    case coordinate(CLLocationCoordinate2D)
    case place(coordinate: CLLocationCoordinate2D, title: String)
    case search(query: String?)
    case measure
    case locate
}

/// Parses and validates custom URL scheme (`mapviewer://`) deep links.
public struct DeepLinkHandler: Sendable {
    public static let urlScheme = "mapviewer"
    
    /// Parses a URL into a strongly-typed DeepLinkDestination.
    public static func parse(url: URL) -> DeepLinkDestination? {
        guard url.scheme?.lowercased() == urlScheme else { return nil }
        
        let host = url.host?.lowercased() ?? url.pathComponents.first?.lowercased()
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        
        func param(_ name: String) -> String? {
            queryItems.first(where: { $0.name.lowercased() == name.lowercased() })?.value
        }
        
        switch host {
        case "coordinate":
            if let latStr = param("lat"), let lonStr = param("lon"),
               let lat = Double(latStr), let lon = Double(lonStr) {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                if coord.isValidCoordinate {
                    return .coordinate(coord)
                }
            }
            return nil
            
        case "place":
            if let latStr = param("lat"), let lonStr = param("lon"),
               let lat = Double(latStr), let lon = Double(lonStr) {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let title = param("title") ?? "Saved Place"
                if coord.isValidCoordinate {
                    return .place(coordinate: coord, title: title)
                }
            }
            return nil
            
        case "search":
            let query = param("q")
            return .search(query: query)
            
        case "measure":
            return .measure
            
        case "locate", "current-location":
            return .locate
            
        default:
            return nil
        }
    }
    
    /// Constructs a deep link URL for a coordinate.
    public static func coordinateURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = "coordinate"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.6f", latitude)),
            URLQueryItem(name: "lon", value: String(format: "%.6f", longitude))
        ]
        return components.url
    }
    
    /// Constructs a deep link URL for a place.
    public static func placeURL(latitude: Double, longitude: Double, title: String) -> URL? {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = "place"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.6f", latitude)),
            URLQueryItem(name: "lon", value: String(format: "%.6f", longitude)),
            URLQueryItem(name: "title", value: title)
        ]
        return components.url
    }
    
    /// Constructs quick action URLs.
    public static let searchURL = URL(string: "\(urlScheme)://search")!
    public static let measureURL = URL(string: "\(urlScheme)://measure")!
    public static let locateURL = URL(string: "\(urlScheme)://locate")!
}
