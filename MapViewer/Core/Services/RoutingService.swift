//
//  RoutingService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import MapKit

/// Protocol declaring routing calculation capabilities.
public protocol RoutingServiceProtocol: Sendable {
    func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: TransportationMode
    ) async throws -> [RouteInfo]
}

/// Production implementation of RoutingServiceProtocol utilizing MKDirections.
public final class RoutingService: RoutingServiceProtocol, Sendable {
    public init() {}
    
    /// Calculates real turn-by-turn routes with alternatives between two coordinates using MKDirections.
    public func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: TransportationMode
    ) async throws -> [RouteInfo] {
        guard source.isValidCoordinate && destination.isValidCoordinate else {
            throw MapViewerError.invalidRouteCoordinates
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destPlacemark = MKPlacemark(coordinate: destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        request.transportType = transportType.mkDirectionsTransportType
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            guard !response.routes.isEmpty else {
                throw MapViewerError.routeNotFound
            }
            
            return response.routes.map { RouteInfo(route: $0, transportType: transportType) }
        } catch let err as MapViewerError {
            throw err
        } catch {
            let nsError = error as NSError
            if nsError.domain == MKErrorDomain && nsError.code == MKError.directionsNotFound.rawValue {
                throw MapViewerError.routeNotFound
            } else {
                throw MapViewerError.searchFailed("Route calculation failed: \(error.localizedDescription)")
            }
        }
    }
}
