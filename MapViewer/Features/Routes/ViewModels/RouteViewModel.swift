//
//  RouteViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Observation

/// ViewModel managing route planning, transport modes, route alternatives, and turn-by-turn navigation steps.
@Observable
@MainActor
public final class RouteViewModel {
    private let routingService: RoutingServiceProtocol
    private let locationService: LocationServiceProtocol
    
    public var startCoordinate: CLLocationCoordinate2D?
    public var startName: String = "My Location"
    public var destinationCoordinate: CLLocationCoordinate2D?
    public var destinationName: String = ""
    public var transportMode: TransportationMode = .automobile
    
    public var routes: [RouteInfo] = []
    public var selectedRouteIndex: Int = 0
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var isSelectingDestinationOnMap: Bool = false
    
    public var activeRoute: RouteInfo? {
        guard !routes.isEmpty, selectedRouteIndex < routes.count else { return nil }
        return routes[selectedRouteIndex]
    }
    
    public init(
        routingService: RoutingServiceProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.routingService = routingService
        self.locationService = locationService
        
        // Default start to current user coordinate if available
        if let userCoord = locationService.currentCoordinate {
            self.startCoordinate = userCoord
            self.startName = "Current Location"
        }
    }
    
    public func setStart(coordinate: CLLocationCoordinate2D, name: String) {
        self.startCoordinate = coordinate
        self.startName = name
        if destinationCoordinate != nil {
            calculateRoute()
        }
    }
    
    public func setDestination(coordinate: CLLocationCoordinate2D, name: String) {
        self.destinationCoordinate = coordinate
        self.destinationName = name
        
        if startCoordinate == nil {
            if let userCoord = locationService.currentCoordinate {
                self.startCoordinate = userCoord
                self.startName = "Current Location"
            }
        }
        
        if startCoordinate != nil {
            calculateRoute()
        }
    }
    
    public func setTransportMode(_ mode: TransportationMode) {
        guard self.transportMode != mode else { return }
        self.transportMode = mode
        if startCoordinate != nil && destinationCoordinate != nil {
            calculateRoute()
        }
    }
    
    public func swapEndpoints() {
        let tempCoord = startCoordinate
        let tempName = startName
        startCoordinate = destinationCoordinate
        startName = destinationName
        destinationCoordinate = tempCoord
        destinationName = tempName
        
        if startCoordinate != nil && destinationCoordinate != nil {
            calculateRoute()
        }
    }
    
    public func calculateRoute() {
        guard let start = startCoordinate, let dest = destinationCoordinate else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let calculatedRoutes = try await routingService.calculateRoute(
                    from: start,
                    to: dest,
                    transportType: transportMode
                )
                self.routes = calculatedRoutes
                self.selectedRouteIndex = 0
                self.isLoading = false
            } catch let err as MapViewerError {
                self.isLoading = false
                self.errorMessage = err.errorDescription
                self.routes = []
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.routes = []
            }
        }
    }
    
    public func clear() {
        self.destinationCoordinate = nil
        self.destinationName = ""
        self.routes = []
        self.selectedRouteIndex = 0
        self.errorMessage = nil
    }
}
