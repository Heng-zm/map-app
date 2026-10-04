//
//  CustomPin.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData
import CoreLocation

/// SwiftData persistent entity for custom map pins created by long-pressing the map.
@Model
public final class CustomPin {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var subtitle: String?
    public var notes: String
    public var latitude: Double
    public var longitude: Double
    public var colorHex: String
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        notes: String = "",
        latitude: Double,
        longitude: Double,
        colorHex: String = "#FF3B30",
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
        self.colorHex = colorHex
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
            updatedAt = Date()
        }
    }
    
    /// Converts persistent CustomPin into in-memory LocationPin struct for MapKit rendering.
    public func toLocationPin() -> LocationPin {
        LocationPin(
            id: id,
            coordinate: coordinate,
            title: title,
            subtitle: subtitle,
            notes: notes,
            colorHex: colorHex,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
