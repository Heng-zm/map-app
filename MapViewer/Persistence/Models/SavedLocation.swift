//
//  SavedLocation.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData
import CoreLocation

/// SwiftData persistent entity for user-saved places and bookmarks.
@Model
public final class SavedLocation {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var notes: String
    public var latitude: Double
    public var longitude: Double
    public var address: String?
    public var category: String?
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        notes: String = "",
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        category: String? = "Personal",
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.category = category
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
}
