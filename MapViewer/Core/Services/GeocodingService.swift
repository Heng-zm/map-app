//
//  GeocodingService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Model containing structured address components from CLPlacemark.
public struct GeocodedAddress: Sendable, Equatable {
    public let name: String?
    public let street: String?
    public let city: String?
    public let state: String?
    public let postalCode: String?
    public let country: String?
    public let formattedAddress: String
    public let coordinate: CLLocationCoordinate2D
    
    public init(
        name: String? = nil,
        street: String? = nil,
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        country: String? = nil,
        formattedAddress: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.formattedAddress = formattedAddress
        self.coordinate = coordinate
    }
    
    public init(placemark: CLPlacemark) {
        self.name = placemark.name
        
        if let subThoroughfare = placemark.subThoroughfare, let thoroughfare = placemark.thoroughfare {
            self.street = "\(subThoroughfare) \(thoroughfare)"
        } else {
            self.street = placemark.thoroughfare
        }
        
        self.city = placemark.locality
        self.state = placemark.administrativeArea
        self.postalCode = placemark.postalCode
        self.country = placemark.country
        self.coordinate = placemark.location?.coordinate ?? kCLLocationCoordinate2DInvalid
        
        // Assemble formatted address
        var components: [String] = []
        if let street = self.street {
            components.append(street)
        }
        if let city = self.city {
            components.append(city)
        }
        if let state = self.state {
            if let postal = self.postalCode {
                components.append("\(state) \(postal)")
            } else {
                components.append(state)
            }
        }
        if let country = self.country {
            components.append(country)
        }
        
        if components.isEmpty {
            self.formattedAddress = placemark.name ?? "Unknown Location"
        } else {
            self.formattedAddress = components.joined(separator: ", ")
        }
    }
}

/// Protocol declaring geocoding and reverse-geocoding capabilities.
public protocol GeocodingServiceProtocol: Sendable {
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> GeocodedAddress
    func geocode(address: String) async throws -> [CLLocationCoordinate2D]
}

/// Production implementation of GeocodingServiceProtocol utilizing CLGeocoder with caching.
public final class GeocodingService: GeocodingServiceProtocol, @unchecked Sendable {
    private let geocoder = CLGeocoder()
    private let cache = NSCache<NSString, BoxedAddress>()
    
    private final class BoxedAddress {
        let value: GeocodedAddress
        init(_ value: GeocodedAddress) { self.value = value }
    }
    
    public init() {}
    
    /// Reverse geocodes a coordinate into a structured address with caching.
    public func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> GeocodedAddress {
        guard coordinate.isValidCoordinate else {
            throw MapViewerError.invalidCoordinates
        }
        
        // Cache key rounded to ~11 meters (4 decimal places)
        let cacheKey = NSString(string: String(format: "%.4f,%.4f", coordinate.latitude, coordinate.longitude))
        if let cached = cache.object(forKey: cacheKey) {
            return cached.value
        }
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let topPlacemark = placemarks.first else {
                throw MapViewerError.geocodingFailed("No address found for these coordinates.")
            }
            
            let address = GeocodedAddress(placemark: topPlacemark)
            cache.setObject(BoxedAddress(address), forKey: cacheKey)
            return address
        } catch let err as MapViewerError {
            throw err
        } catch {
            throw MapViewerError.geocodingFailed(error.localizedDescription)
        }
    }
    
    /// Forward geocodes an address string into geographic coordinates.
    public func geocode(address: String) async throws -> [CLLocationCoordinate2D] {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw MapViewerError.emptySearchQuery
        }
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(trimmed)
            let coordinates = placemarks.compactMap { $0.location?.coordinate }.filter { $0.isValidCoordinate }
            if coordinates.isEmpty {
                throw MapViewerError.noSearchResults
            }
            return coordinates
        } catch let err as MapViewerError {
            throw err
        } catch {
            throw MapViewerError.geocodingFailed(error.localizedDescription)
        }
    }
}
