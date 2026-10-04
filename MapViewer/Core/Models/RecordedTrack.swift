//
//  RecordedTrack.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Supported activity types for GPS track recording.
public enum TrackActivityType: String, CaseIterable, Codable, Identifiable, Sendable {
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case hiking = "Hiking"
    case driving = "Driving"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .hiking: return "figure.hiking"
        case .driving: return "car.fill"
        }
    }
}

/// A single timestamped GPS coordinate recorded along a track.
public struct TrackPoint: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public let latitude: Double
    public let longitude: Double
    public let altitude: Double?
    public let speed: Double? // meters per second
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        speed: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.timestamp = timestamp
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Complete recorded GPS track session with metadata and statistics.
public struct RecordedTrack: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var activityType: TrackActivityType
    public var points: [TrackPoint]
    public let startTime: Date
    public var endTime: Date?
    public var distanceMeters: Double
    public var durationSeconds: TimeInterval
    public var elevationGainMeters: Double
    public var maxSpeedMps: Double
    
    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        activityType: TrackActivityType = .hiking,
        points: [TrackPoint] = [],
        startTime: Date = Date(),
        endTime: Date? = nil,
        distanceMeters: Double = 0.0,
        durationSeconds: TimeInterval = 0.0,
        elevationGainMeters: Double = 0.0,
        maxSpeedMps: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.activityType = activityType
        self.points = points
        self.startTime = startTime
        self.endTime = endTime
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.elevationGainMeters = elevationGainMeters
        self.maxSpeedMps = maxSpeedMps
    }
    
    public var averageSpeedKmh: Double {
        guard durationSeconds > 0 else { return 0.0 }
        let speedMps = distanceMeters / durationSeconds
        return speedMps * 3.6
    }
    
    public var maxSpeedKmh: Double {
        maxSpeedMps * 3.6
    }
    
    public var coordinates: [CLLocationCoordinate2D] {
        points.map { $0.coordinate }
    }
}
