//
//  RouteInfo.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import MapKit

/// Represents an individual navigation step within a calculated route.
public struct RouteStep: Identifiable, Sendable {
    public let id: UUID
    public let instructions: String
    public let notice: String?
    public let distance: Double
    public let transportType: TransportationMode
    
    public init(
        id: UUID = UUID(),
        instructions: String,
        notice: String? = nil,
        distance: Double,
        transportType: TransportationMode
    ) {
        self.id = id
        self.instructions = instructions
        self.notice = notice
        self.distance = distance
        self.transportType = transportType
    }
}

/// Production model encapsulating calculated route information.
public struct RouteInfo: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let transportType: TransportationMode
    public let distance: Double // in meters
    public let expectedTravelTime: TimeInterval // in seconds
    public let advisoryNotices: [String]
    public let polylineCoordinates: [CLLocationCoordinate2D]
    public let steps: [RouteStep]
    public let boundingMapRect: MKMapRect
    
    public init(
        id: UUID = UUID(),
        name: String,
        transportType: TransportationMode,
        distance: Double,
        expectedTravelTime: TimeInterval,
        advisoryNotices: [String] = [],
        polylineCoordinates: [CLLocationCoordinate2D],
        steps: [RouteStep] = [],
        boundingMapRect: MKMapRect = .null
    ) {
        self.id = id
        self.name = name
        self.transportType = transportType
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.advisoryNotices = advisoryNotices
        self.polylineCoordinates = polylineCoordinates
        self.steps = steps
        self.boundingMapRect = boundingMapRect
    }
    
    /// Initializes RouteInfo from an MKRoute instance.
    public init(route: MKRoute, transportType: TransportationMode) {
        self.id = UUID()
        self.name = route.name.isEmpty ? "Suggested Route" : route.name
        self.transportType = transportType
        self.distance = route.distance
        self.expectedTravelTime = route.expectedTravelTime
        self.advisoryNotices = route.advisoryNotices
        self.boundingMapRect = route.polyline.boundingMapRect
        
        // Extract polyline coordinates
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: route.polyline.pointCount)
        route.polyline.getCoordinates(&coords, range: NSRange(location: 0, length: route.polyline.pointCount))
        self.polylineCoordinates = coords
        
        // Extract steps
        self.steps = route.steps
            .filter { !$0.instructions.isEmpty }
            .map { step in
                RouteStep(
                    instructions: step.instructions,
                    notice: step.notice,
                    distance: step.distance,
                    transportType: transportType
                )
            }
    }
}
