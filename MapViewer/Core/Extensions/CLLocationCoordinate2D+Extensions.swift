//
//  CLLocationCoordinate2D+Extensions.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        abs(lhs.latitude - rhs.latitude) < 0.0000001 &&
        abs(lhs.longitude - rhs.longitude) < 0.0000001
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension CLLocationCoordinate2D: @retroactive Sendable {}

extension CLLocationCoordinate2D {
    /// Checks if the coordinate is within valid geographic boundaries.
    public var isValidCoordinate: Bool {
        CLLocationCoordinate2DIsValid(self) &&
        latitude >= -90.0 && latitude <= 90.0 &&
        longitude >= -180.0 && longitude <= 180.0
    }
    
    /// Calculates the great-circle distance in meters to another coordinate using CoreLocation.
    public func distance(to destination: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    /// Default coordinate fallback when location is unavailable (Cupertino, CA / Apple Park).
    public static let applePark = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
    
    /// Default San Francisco coordinate.
    public static let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
}
