//
//  SearchViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI
import MapKit
import Observation

/// ViewModel managing autocomplete queries, search execution, search history, and place selection.
@Observable
@MainActor
public final class SearchViewModel {
    private let searchService: SearchServiceProtocol
    private let searchHistoryRepository: SearchHistoryRepositoryProtocol
    
    public var queryText: String = "" {
        didSet {
            handleQueryChange()
        }
    }
    
    public var searchResults: [PlaceSearchResult] = []
    public var recentSearches: [SearchHistoryItem] = []
    public var selectedPlace: PlaceSearchResult?
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var activeRegion: MKCoordinateRegion?
    
    private var debounceTask: Task<Void, Never>?
    
    public var completions: [MKLocalSearchCompletion] {
        searchService.completions
    }
    
    public init(
        searchService: SearchServiceProtocol,
        searchHistoryRepository: SearchHistoryRepositoryProtocol
    ) {
        self.searchService = searchService
        self.searchHistoryRepository = searchHistoryRepository
        loadHistory()
    }
    
    // MARK: - Query & Autocomplete
    
    private func handleQueryChange() {
        debounceTask?.cancel()
        
        let trimmed = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchService.updateCompletions(query: "", region: activeRegion)
            searchResults = []
            return
        }
        
        // Debounce autocomplete by 250ms
        debounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled, let self = self else { return }
            self.searchService.updateCompletions(query: trimmed, region: self.activeRegion)
        }
    }
    
    // MARK: - Execution
    
    public func performSearch(query: String? = nil) {
        let searchQuery = (query ?? queryText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await searchService.search(query: searchQuery, region: activeRegion)
                self.searchResults = results
                self.isLoading = false
                
                // Save query into recent search history
                if let topResult = results.first {
                    try? self.searchHistoryRepository.add(
                        query: searchQuery,
                        title: topResult.title,
                        subtitle: topResult.subtitle,
                        coordinate: topResult.coordinate
                    )
                } else {
                    try? self.searchHistoryRepository.add(
                        query: searchQuery,
                        title: searchQuery,
                        subtitle: "",
                        coordinate: nil
                    )
                }
                self.loadHistory()
            } catch is CancellationError {
                self.isLoading = false
            } catch let err as MapViewerError {
                self.isLoading = false
                self.errorMessage = err.errorDescription
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func selectCompletion(_ completion: MKLocalSearchCompletion) {
        self.queryText = completion.title
        performSearch(query: completion.title + " " + completion.subtitle)
    }
    
    public func searchCategory(_ category: MKPointOfInterestCategory) {
        guard let region = activeRegion else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await searchService.searchNearby(category: category, region: region)
                self.searchResults = results
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - History
    
    public func loadHistory() {
        do {
            self.recentSearches = try searchHistoryRepository.fetchRecent(limit: 20)
        } catch {
            self.recentSearches = []
        }
    }
    
    public func deleteHistoryItem(_ item: SearchHistoryItem) {
        do {
            try searchHistoryRepository.delete(item)
            loadHistory()
        } catch {
            self.errorMessage = "Failed to remove history item."
        }
    }
    
    public func clearHistory() {
        do {
            try searchHistoryRepository.clearAll()
            self.recentSearches = []
        } catch {
            self.errorMessage = "Failed to clear search history."
        }
    }
    
    public func selectResult(_ place: PlaceSearchResult) {
        self.selectedPlace = place
    }
}
