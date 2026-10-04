//
//  SwiftDataSearchHistoryRepository.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftData
import CoreLocation

/// Production SwiftData-backed repository for SearchHistoryItem records.
@MainActor
public final class SwiftDataSearchHistoryRepository: SearchHistoryRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let maxHistoryCount = 50
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }
    
    @MainActor
    public func fetchRecent(limit: Int = 20) throws -> [SearchHistoryItem] {
        do {
            var descriptor = FetchDescriptor<SearchHistoryItem>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try context.fetch(descriptor)
        } catch {
            throw MapViewerError.persistenceFailed("Failed to fetch search history: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func add(query: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D?) throws {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        do {
            // Check for existing identical query to prevent duplicates
            let fetchDescriptor = FetchDescriptor<SearchHistoryItem>()
            let existingItems = try context.fetch(fetchDescriptor)
            
            if let existing = existingItems.first(where: { $0.query.lowercased() == trimmedQuery.lowercased() }) {
                existing.timestamp = Date()
                existing.title = title
                existing.subtitle = subtitle
                existing.latitude = coordinate?.latitude
                existing.longitude = coordinate?.longitude
            } else {
                let newItem = SearchHistoryItem(
                    query: trimmedQuery,
                    title: title,
                    subtitle: subtitle,
                    latitude: coordinate?.latitude,
                    longitude: coordinate?.longitude,
                    timestamp: Date()
                )
                context.insert(newItem)
            }
            
            // Prune excess if over limit
            let all = try context.fetch(FetchDescriptor<SearchHistoryItem>(sortBy: [SortDescriptor(\.timestamp, order: .descending)]))
            if all.count > maxHistoryCount {
                for item in all.dropFirst(maxHistoryCount) {
                    context.delete(item)
                }
            }
            
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to save search history: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func delete(_ item: SearchHistoryItem) throws {
        do {
            let targetId = item.id
            let all = try context.fetch(FetchDescriptor<SearchHistoryItem>())
            for existing in all where existing.id == targetId {
                context.delete(existing)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to delete search history item: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func clearAll() throws {
        do {
            let descriptor = FetchDescriptor<SearchHistoryItem>()
            let allItems = try context.fetch(descriptor)
            for item in allItems {
                context.delete(item)
            }
            try context.save()
        } catch {
            throw MapViewerError.persistenceFailed("Failed to clear search history: \(error.localizedDescription)")
        }
    }
}
