//
//  MKCoordinateRegion+Extensions.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import MapKit

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center &&
        abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta) < 0.0001 &&
        abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta) < 0.0001
    }
}

extension MKCoordinateRegion {
    /// Creates a focused region around a coordinate with delta in meters.
    public init(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        self = MKCoordinateRegion(
            center: center,
            latitudinalMeters: latitudinalMeters,
            longitudinalMeters: longitudinalMeters
        )
    }
    
    /// Default initial region for Map Viewer.
    public static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D.sanFrancisco,
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    
    /// Clamps delta spans to safe, valid bounds.
    public var clamped: MKCoordinateRegion {
        let latDelta = min(max(span.latitudeDelta, 0.001), 160.0)
        let lonDelta = min(max(span.longitudeDelta, 0.001), 160.0)
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}
