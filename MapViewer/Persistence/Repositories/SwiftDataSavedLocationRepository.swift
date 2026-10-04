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
            let predicate = #Predicate<SavedLocation> { $0.isFavorite == true }
            let descriptor = FetchDescriptor<SavedLocation>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            throw MapViewerError.persistenceFailed("Failed to fetch favorites: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func save(_ location: SavedLocation) throws {
        do {
            context.insert(location)
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to save location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func update(_ location: SavedLocation) throws {
        do {
            location.updatedAt = Date()
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to update location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func delete(_ location: SavedLocation) throws {
        do {
            context.delete(location)
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
            context.insert(pin)
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to save custom pin: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func updatePin(_ pin: CustomPin) throws {
        do {
            pin.updatedAt = Date()
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to update custom pin: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func deletePin(_ pin: CustomPin) throws {
        do {
            context.delete(pin)
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to delete custom pin: \(error.localizedDescription)")
        }
    }
}
