//
//  SavedLocationsViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import Observation

/// Sorting criteria for saved locations.
public enum SavedLocationSortOption: String, CaseIterable, Identifiable {
    case dateAdded = "Date Added"
    case name = "Name (A-Z)"
    case distance = "Distance"
    
    public var id: String { rawValue }
}

/// ViewModel coordinating saved locations list, category filters, sorting, and editing.
@Observable
@MainActor
public final class SavedLocationsViewModel {
    private let repository: SavedLocationRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    public var locations: [SavedLocation] = []
    public var filterText: String = ""
    public var selectedCategory: String? = nil
    public var showFavoritesOnly: Bool = false
    public var sortOption: SavedLocationSortOption = .dateAdded
    public var selectedLocationForEdit: SavedLocation?
    public var isEditSheetPresented: Bool = false
    public var errorMessage: String?
    
    public init(
        repository: SavedLocationRepositoryProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.repository = repository
        self.locationService = locationService
        loadLocations()
    }
    
    public func loadLocations() {
        do {
            self.locations = try repository.fetchAll()
        } catch {
            self.errorMessage = "Failed to load saved locations: \(error.localizedDescription)"
        }
    }
    
    /// Derived list of unique categories.
    public var availableCategories: [String] {
        let set = Set(locations.compactMap { $0.category }.filter { !$0.isEmpty })
        return ["All"] + Array(set).sorted()
    }
    
    /// Filtered and sorted locations list.
    public var filteredLocations: [SavedLocation] {
        var result = locations
        
        // Filter by favorites
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        // Filter by category
        if let cat = selectedCategory, cat != "All" {
            result = result.filter { $0.category == cat }
        }
        
        // Filter by search text
        let query = filterText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query) ||
                ($0.address?.lowercased().contains(query) ?? false) ||
                ($0.category?.lowercased().contains(query) ?? false)
            }
        }
        
        // Sort
        switch sortOption {
        case .dateAdded:
            result.sort { $0.createdAt > $1.createdAt }
        case .name:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .distance:
            if let userCoord = locationService.currentCoordinate {
                result.sort {
                    $0.coordinate.distance(to: userCoord) < $1.coordinate.distance(to: userCoord)
                }
            }
        }
        
        return result
    }
    
    // MARK: - CRUD
    
    public func toggleFavorite(_ location: SavedLocation) {
        do {
            try repository.toggleFavorite(location)
            loadLocations()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func saveLocation(
        name: String,
        notes: String,
        coordinate: CLLocationCoordinate2D,
        address: String?,
        category: String?,
        isFavorite: Bool
    ) {
        let item = SavedLocation(
            name: name,
            notes: notes,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: address,
            category: category,
            isFavorite: isFavorite
        )
        do {
            try repository.save(item)
            loadLocations()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func updateLocation(
        _ location: SavedLocation,
        name: String,
        notes: String,
        category: String?,
        isFavorite: Bool
    ) {
        location.name = name
        location.notes = notes
        location.category = category
        location.isFavorite = isFavorite
        location.updatedAt = Date()
        
        do {
            try repository.update(location)
            loadLocations()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func deleteLocation(_ location: SavedLocation) {
        do {
            try repository.delete(location)
            loadLocations()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
