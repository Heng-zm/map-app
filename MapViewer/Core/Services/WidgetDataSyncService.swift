//
//  WidgetDataSyncService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import WidgetKit

/// Snapshot model representing last known user coordinate for widgets.
public struct WidgetCoordinateSnapshot: Codable, Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let formattedDD: String
    public let formattedDMS: String
    public let altitudeMeters: Double?
    public let headingDegrees: Double?
    public let updatedAt: Date
    
    public init(
        latitude: Double,
        longitude: Double,
        formattedDD: String,
        formattedDMS: String,
        altitudeMeters: Double? = nil,
        headingDegrees: Double? = nil,
        updatedAt: Date = Date()
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.formattedDD = formattedDD
        self.formattedDMS = formattedDMS
        self.altitudeMeters = altitudeMeters
        self.headingDegrees = headingDegrees
        self.updatedAt = updatedAt
    }
}

/// Lightweight model representing a favorite place for widgets.
public struct WidgetPlaceItem: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let subtitle: String
    public let latitude: Double
    public let longitude: Double
    public let category: String
    public let distanceMeters: Double?
    public let formattedDistance: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        latitude: Double,
        longitude: Double,
        category: String = "Favorite",
        distanceMeters: Double? = nil,
        formattedDistance: String? = nil
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.distanceMeters = distanceMeters
        self.formattedDistance = formattedDistance
    }
}

/// Top-level shared snapshot data model persisted for WidgetKit extensions.
public struct WidgetSnapshotData: Codable, Equatable, Sendable {
    public var coordinate: WidgetCoordinateSnapshot?
    public var favoritePlaces: [WidgetPlaceItem]
    public var lastSyncTime: Date
    
    public init(
        coordinate: WidgetCoordinateSnapshot? = nil,
        favoritePlaces: [WidgetPlaceItem] = [],
        lastSyncTime: Date = Date()
    ) {
        self.coordinate = coordinate
        self.favoritePlaces = favoritePlaces
        self.lastSyncTime = lastSyncTime
    }
    
    public static let empty = WidgetSnapshotData(
        coordinate: nil,
        favoritePlaces: [],
        lastSyncTime: Date()
    )
    
    public static let preview = WidgetSnapshotData(
        coordinate: WidgetCoordinateSnapshot(
            latitude: 37.7749,
            longitude: -122.4194,
            formattedDD: "37.7749° N, 122.4194° W",
            formattedDMS: "37° 46' 29.64\" N, 122° 25' 09.84\" W",
            altitudeMeters: 45.0,
            headingDegrees: 312.0
        ),
        favoritePlaces: [
            WidgetPlaceItem(
                name: "Ferry Building",
                subtitle: "1 Ferry Building, SF",
                latitude: 37.7955,
                longitude: -122.3937,
                category: "Landmark",
                distanceMeters: 1420.0,
                formattedDistance: "1.42 km"
            ),
            WidgetPlaceItem(
                name: "Golden Gate Bridge",
                subtitle: "Golden Gate Bridge, SF",
                latitude: 37.8199,
                longitude: -122.4783,
                category: "Sightseeing",
                distanceMeters: 6200.0,
                formattedDistance: "6.20 km"
            ),
            WidgetPlaceItem(
                name: "Twin Peaks Viewpoint",
                subtitle: "501 Twin Peaks Blvd",
                latitude: 37.7544,
                longitude: -122.4477,
                category: "Scenic",
                distanceMeters: 3800.0,
                formattedDistance: "3.80 km"
            )
        ],
        lastSyncTime: Date()
    )
}

/// Service synchronizing live app state to shared UserDefaults for WidgetKit.
public final class WidgetDataSyncService: @unchecked Sendable {
    public static let shared = WidgetDataSyncService()
    public static let appGroupId = "group.com.antigravity.mapviewer"
    private static let storageKey = "mv_widget_snapshot_data"
    
    private let userDefaults: UserDefaults
    
    public init(defaults: UserDefaults = UserDefaults(suiteName: appGroupId) ?? .standard) {
        self.userDefaults = defaults
    }
    
    /// Updates widget snapshot with latest coordinate, heading, and altitude.
    public func syncLocation(
        coordinate: CLLocationCoordinate2D,
        altitude: Double? = nil,
        heading: Double? = nil
    ) {
        guard coordinate.isValidCoordinate else { return }
        var snapshot = readSnapshot()
        let dd = CoordinateFormatter.shared.formatDecimalDegrees(coordinate, precision: 4)
        let dms = CoordinateFormatter.shared.formatDMS(coordinate)
        
        snapshot.coordinate = WidgetCoordinateSnapshot(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            formattedDD: dd,
            formattedDMS: dms,
            altitudeMeters: altitude,
            headingDegrees: heading,
            updatedAt: Date()
        )
        snapshot.lastSyncTime = Date()
        saveSnapshot(snapshot)
        notifyWidgetCenter()
    }
    
    /// Updates widget snapshot with user's favorite places and relative distances.
    public func syncFavorites(places: [SavedLocation], userLocation: CLLocationCoordinate2D? = nil) {
        var snapshot = readSnapshot()
        snapshot.favoritePlaces = places.prefix(6).map { loc in
            var distMeters: Double? = nil
            var distStr: String? = nil
            if let userCoord = userLocation {
                let dist = loc.coordinate.distance(to: userCoord)
                distMeters = dist
                distStr = UnitFormatter.shared.formatDistance(dist, system: .metric)
            }
            return WidgetPlaceItem(
                id: loc.id,
                name: loc.name,
                subtitle: loc.address ?? loc.category ?? "",
                latitude: loc.latitude,
                longitude: loc.longitude,
                category: loc.category ?? "Favorite",
                distanceMeters: distMeters,
                formattedDistance: distStr
            )
        }
        snapshot.lastSyncTime = Date()
        saveSnapshot(snapshot)
        notifyWidgetCenter()
    }
    
    private func notifyWidgetCenter() {
        if NSClassFromString("XCTestCase") == nil {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Reads persisted snapshot from shared store.
    public func readSnapshot() -> WidgetSnapshotData {
        guard let data = userDefaults.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshotData.self, from: data) else {
            return .empty
        }
        return snapshot
    }
    
    /// Persists snapshot to shared store.
    public func saveSnapshot(_ snapshot: WidgetSnapshotData) {
        if let encoded = try? JSONEncoder().encode(snapshot) {
            userDefaults.set(encoded, forKey: Self.storageKey)
        }
    }
}
