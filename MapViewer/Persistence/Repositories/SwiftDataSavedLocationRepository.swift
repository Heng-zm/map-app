//
//  SwiftDataSavedLocationRepository.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData

/// Production SwiftData-backed repository for SavedLocation and CustomPin entities.
@MainActor
public final class SwiftDataSavedLocationRepository: SavedLocationRepositoryProtocol {
    private let modelContainer: ModelContainer
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }
    
    // MARK: - Saved Locations
    
    @MainActor
    public func fetchAll() throws -> [SavedLocation] {
        do {
            let descriptor = FetchDescriptor<SavedLocation>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            throw MapViewerError.persistenceFailed("Failed to fetch saved locations: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func fetchFavorites() throws -> [SavedLocation] {
        do {
            let all = try fetchAll()
            return all.filter { $0.isFavorite }
        } catch {
            throw MapViewerError.persistenceFailed("Failed to fetch favorites: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func save(_ location: SavedLocation) throws {
        do {
            let all = try context.fetch(FetchDescriptor<SavedLocation>())
            if let existing = all.first(where: { $0.id == location.id }) {
                existing.name = location.name
                existing.notes = location.notes
                existing.latitude = location.latitude
                existing.longitude = location.longitude
                existing.address = location.address
                existing.category = location.category
                existing.isFavorite = location.isFavorite
                existing.updatedAt = Date()
            } else {
                context.insert(location)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to save location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func update(_ location: SavedLocation) throws {
        do {
            let all = try context.fetch(FetchDescriptor<SavedLocation>())
            if let existing = all.first(where: { $0.id == location.id }) {
                existing.name = location.name
                existing.notes = location.notes
                existing.latitude = location.latitude
                existing.longitude = location.longitude
                existing.address = location.address
                existing.category = location.category
                existing.isFavorite = location.isFavorite
                existing.updatedAt = Date()
            } else {
                location.updatedAt = Date()
                if location.modelContext == nil {
                    context.insert(location)
                }
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to update location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func delete(_ location: SavedLocation) throws {
        do {
            let all = try context.fetch(FetchDescriptor<SavedLocation>())
            for item in all where item.id == location.id {
                context.delete(item)
            }
            if location.modelContext != nil {
                context.delete(location)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to delete location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func toggleFavorite(_ location: SavedLocation) throws {
        do {
            location.isFavorite.toggle()
            location.updatedAt = Date()
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to toggle favorite: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom Pins
    
    @MainActor
    public func fetchAllPins() throws -> [CustomPin] {
        do {
            let descriptor = FetchDescriptor<CustomPin>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            throw MapViewerError.persistenceFailed("Failed to fetch custom pins: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func savePin(_ pin: CustomPin) throws {
        do {
            let all = try context.fetch(FetchDescriptor<CustomPin>())
            if let existing = all.first(where: { $0.id == pin.id }) {
                existing.title = pin.title
                existing.subtitle = pin.subtitle
                existing.notes = pin.notes
                existing.latitude = pin.latitude
                existing.longitude = pin.longitude
                existing.colorHex = pin.colorHex
                existing.isFavorite = pin.isFavorite
                existing.updatedAt = Date()
            } else {
                context.insert(pin)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to save custom pin: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func updatePin(_ pin: CustomPin) throws {
        do {
            let all = try context.fetch(FetchDescriptor<CustomPin>())
            if let existing = all.first(where: { $0.id == pin.id }) {
                existing.title = pin.title
                existing.subtitle = pin.subtitle
                existing.notes = pin.notes
                existing.latitude = pin.latitude
                existing.longitude = pin.longitude
                existing.colorHex = pin.colorHex
                existing.isFavorite = pin.isFavorite
                existing.updatedAt = Date()
            } else {
                context.insert(pin)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to update custom pin: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func deletePin(_ pin: CustomPin) throws {
        do {
            let all = try context.fetch(FetchDescriptor<CustomPin>())
            for existing in all where existing.id == pin.id {
                context.delete(existing)
            }
            if pin.modelContext != nil {
                context.delete(pin)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to delete custom pin: \(error.localizedDescription)")
        }
    }
}
