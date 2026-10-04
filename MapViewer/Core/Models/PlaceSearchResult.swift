//
//  PlaceSearchResult.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import MapKit

/// Domain representation of a place found via MKLocalSearch or MKLocalSearchCompleter.
public struct PlaceSearchResult: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let title: String
    public let subtitle: String
    public let coordinate: CLLocationCoordinate2D
    public let address: String?
    public let category: String?
    public let phoneNumber: String?
    public let url: URL?
    public let timeZone: TimeZone?
    
    public init(
        id: UUID = UUID(),
        name: String,
        title: String,
        subtitle: String,
        coordinate: CLLocationCoordinate2D,
        address: String? = nil,
        category: String? = nil,
        phoneNumber: String? = nil,
        url: URL? = nil,
        timeZone: TimeZone? = nil
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.address = address
        self.category = category
        self.phoneNumber = phoneNumber
        self.url = url
        self.timeZone = timeZone
    }
    
    /// Initializes a PlaceSearchResult from a real MKMapItem.
    public init(mapItem: MKMapItem) {
        self.id = UUID()
        self.name = mapItem.name ?? "Unknown Location"
        self.title = mapItem.name ?? "Unknown Location"
        
        let placemark = mapItem.placemark
        var subtitleParts: [String] = []
        if let locality = placemark.locality {
            subtitleParts.append(locality)
        }
        if let adminArea = placemark.administrativeArea {
            subtitleParts.append(adminArea)
        }
        if let country = placemark.country {
            subtitleParts.append(country)
        }
        self.subtitle = subtitleParts.isEmpty ? (placemark.title ?? "") : subtitleParts.joined(separator: ", ")
        self.coordinate = placemark.coordinate
        
        // Build address string
        var addressComponents: [String] = []
        if let subThoroughfare = placemark.subThoroughfare, let thoroughfare = placemark.thoroughfare {
            addressComponents.append("\(subThoroughfare) \(thoroughfare)")
        } else if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let admin = placemark.administrativeArea {
            if let postal = placemark.postalCode {
                addressComponents.append("\(admin) \(postal)")
            } else {
                addressComponents.append(admin)
            }
        }
        if let country = placemark.country {
            addressComponents.append(country)
        }
        self.address = addressComponents.isEmpty ? placemark.title : addressComponents.joined(separator: ", ")
        
        if let poiCategory = mapItem.pointOfInterestCategory {
            self.category = poiCategory.rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
        } else {
            self.category = nil
        }
        
        self.phoneNumber = mapItem.phoneNumber
        self.url = mapItem.url
        self.timeZone = mapItem.timeZone
    }
    
    public static func == (lhs: PlaceSearchResult, rhs: PlaceSearchResult) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
