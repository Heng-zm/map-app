//
//  GeodesicCalculator.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Provides geodesic calculations for distance, perimeter, and polygon area on the Earth's surface.
public final class GeodesicCalculator: Sendable {
    public static let shared = GeodesicCalculator()
    
    /// Mean authalic radius of the Earth in meters (WGS-84 standard).
    public static let earthRadiusMeters: Double = 6_371_008.8
    
    public init() {}
    
    // MARK: - Distance Calculations
    
    /// Calculates the great-circle distance between two geographic coordinates using the Haversine formula.
    public func haversineDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        guard coord1.isValidCoordinate && coord2.isValidCoordinate else { return 0.0 }
        
        let lat1Rad = coord1.latitude * .pi / 180.0
        let lat2Rad = coord2.latitude * .pi / 180.0
        let dLat = (coord2.latitude - coord1.latitude) * .pi / 180.0
        let dLon = (coord2.longitude - coord1.longitude) * .pi / 180.0
        
        let a = sin(dLat / 2.0) * sin(dLat / 2.0) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(dLon / 2.0) * sin(dLon / 2.0)
        
        let c = 2.0 * atan2(sqrt(a), sqrt(max(0.0, 1.0 - a)))
        return Self.earthRadiusMeters * c
    }
    
    /// Calculates the total path distance in meters along an ordered array of coordinates.
    public func pathDistance(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 2 else { return 0.0 }
        
        var total: Double = 0.0
        for i in 0..<(coordinates.count - 1) {
            total += haversineDistance(from: coordinates[i], to: coordinates[i + 1])
        }
        return total
    }
    
    /// Calculates individual segment distances between adjacent points.
    public func segmentDistances(coordinates: [CLLocationCoordinate2D]) -> [Double] {
        guard coordinates.count >= 2 else { return [] }
        
        var segments: [Double] = []
        for i in 0..<(coordinates.count - 1) {
            segments.append(haversineDistance(from: coordinates[i], to: coordinates[i + 1]))
        }
        return segments
    }
    
    // MARK: - Polygon Calculations
    
    /// Calculates the perimeter in meters of a closed polygon formed by the coordinates.
    public func polygonPerimeter(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 3 else {
            return pathDistance(coordinates: coordinates)
        }
        
        var perimeter = pathDistance(coordinates: coordinates)
        // Add closing segment
        perimeter += haversineDistance(from: coordinates.last!, to: coordinates.first!)
        return perimeter
    }
    
    /// Calculates the geodesic area of a spherical polygon in square meters using the Chamberlain-Duquette algorithm.
    public func polygonArea(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 3 else { return 0.0 }
        
        var total: Double = 0.0
        let count = coordinates.count
        
        for i in 0..<count {
            let p1 = coordinates[i]
            let p2 = coordinates[(i + 1) % count]
            
            let lat1 = p1.latitude * .pi / 180.0
            let lat2 = p2.latitude * .pi / 180.0
            
            var dLon = (p2.longitude - p1.longitude) * .pi / 180.0
            // Normalize dLon to [-π, π]
            while dLon > .pi { dLon -= 2.0 * .pi }
            while dLon < -.pi { dLon += 2.0 * .pi }
            
            total += dLon * (2.0 + sin(lat1) + sin(lat2))
        }
        
        let r = Self.earthRadiusMeters
        var area = abs(total * (r * r) / 2.0)
        
        // Ensure area does not exceed hemisphere; if so, polygon orientation was inverted
        let sphereArea = 4.0 * .pi * (r * r)
        if area > sphereArea / 2.0 {
            area = sphereArea - area
        }
        
        return area
    }
}
