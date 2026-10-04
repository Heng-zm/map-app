//
//  MeasurementItem.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Mode of measurement on the map.
public enum MeasurementMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case distance = "distance"
    case area = "area"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .distance:
            return "Distance Path"
        case .area:
            return "Polygon Area"
        }
    }
    
    public var iconName: String {
        switch self {
        case .distance:
            return "ruler"
        case .area:
            return "square.dashed"
        }
    }
}

/// Represents an individual waypoint placed for geographic measurement.
public struct MeasurementPoint: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let index: Int
    
    public init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, index: Int) {
        self.id = id
        self.coordinate = coordinate
        self.index = index
    }
    
    public static func == (lhs: MeasurementPoint, rhs: MeasurementPoint) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.index == rhs.index
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Calculated measurement results containing distance, segments, and polygon area.
public struct MeasurementResult: Equatable, Sendable {
    public let totalDistance: Double // in meters
    public let segmentDistances: [Double] // in meters
    public let polygonArea: Double // in square meters
    public let perimeter: Double // in meters
    public let pointCount: Int
    
    public static let empty = MeasurementResult(
        totalDistance: 0,
        segmentDistances: [],
        polygonArea: 0,
        perimeter: 0,
        pointCount: 0
    )
    
    public init(
        totalDistance: Double,
        segmentDistances: [Double],
        polygonArea: Double,
        perimeter: Double,
        pointCount: Int
    ) {
        self.totalDistance = totalDistance
        self.segmentDistances = segmentDistances
        self.polygonArea = polygonArea
        self.perimeter = perimeter
        self.pointCount = pointCount
    }
}
