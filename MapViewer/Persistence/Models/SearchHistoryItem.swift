//
//  SearchHistoryItem.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData
import CoreLocation

/// SwiftData persistent entity for recent searches and queries.
@Model
public final class SearchHistoryItem {
    @Attribute(.unique) public var id: UUID
    public var query: String
    public var title: String
    public var subtitle: String
    public var latitude: Double?
    public var longitude: Double?
    public var timestamp: Date
    
    public init(
        id: UUID = UUID(),
        query: String,
        title: String,
        subtitle: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.query = query
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
