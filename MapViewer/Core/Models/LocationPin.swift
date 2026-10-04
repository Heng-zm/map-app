//
//  LocationPin.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import SwiftUI

/// Represents a custom pin placed on the map.
public struct LocationPin: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var coordinate: CLLocationCoordinate2D
    public var title: String
    public var subtitle: String?
    public var notes: String
    public var colorHex: String
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String? = nil,
        notes: String = "",
        colorHex: String = "#FF3B30",
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.colorHex = colorHex
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public static func == (lhs: LocationPin, rhs: LocationPin) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.notes == rhs.notes &&
        lhs.colorHex == rhs.colorHex &&
        lhs.isFavorite == rhs.isFavorite
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
