//
//  SearchService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import MapKit
import Observation

/// Protocol declaring the contract for autocomplete suggestions and place search.
@MainActor
public protocol SearchServiceProtocol: AnyObject, Sendable {
    var completions: [MKLocalSearchCompletion] { get }
    var isSearching: Bool { get }
    var searchError: MapViewerError? { get }
    
    func updateCompletions(query: String, region: MKCoordinateRegion?)
    func search(query: String, region: MKCoordinateRegion?) async throws -> [PlaceSearchResult]
    func searchNearby(category: MKPointOfInterestCategory, region: MKCoordinateRegion) async throws -> [PlaceSearchResult]
    func cancelSearch()
}

/// Production search service utilizing MKLocalSearchCompleter and MKLocalSearch.
@Observable
@MainActor
public final class SearchService: NSObject, SearchServiceProtocol, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    private var activeSearchTask: Task<[PlaceSearchResult], Error>?
    private var activeLocalSearch: MKLocalSearch?
    
    public private(set) var completions: [MKLocalSearchCompletion] = []
    public private(set) var isSearching: Bool = false
    public private(set) var searchError: MapViewerError?
    
    public override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address, .pointOfInterest]
    }
    
    /// Updates autocomplete suggestions from user query text.
    public func updateCompletions(query: String, region: MKCoordinateRegion?) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completer.queryFragment = ""
            completions = []
            return
        }
        
        if let region = region {
            completer.region = region
        }
        completer.queryFragment = trimmed
    }
    
    /// Executes a full text search using MKLocalSearch.
    public func search(query: String, region: MKCoordinateRegion?) async throws -> [PlaceSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw MapViewerError.emptySearchQuery
        }
        
        cancelSearch()
        isSearching = true
        searchError = nil
        
        let task = Task<[PlaceSearchResult], Error> { @MainActor [weak self] in
            guard let self = self else { throw MapViewerError.operationCancelled }
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = trimmed
            request.resultTypes = [.address, .pointOfInterest]
            if let region = region {
                request.region = region
            }
            
            let localSearch = MKLocalSearch(request: request)
            self.activeLocalSearch = localSearch
            
            do {
                let response = try await localSearch.start()
                try Task.checkCancellation()
                
                self.isSearching = false
                let results = response.mapItems.map { PlaceSearchResult(mapItem: $0) }
                if results.isEmpty {
                    self.searchError = .noSearchResults
                }
                return results
            } catch is CancellationError {
                self.isSearching = false
                throw MapViewerError.operationCancelled
            } catch {
                self.isSearching = false
                let customErr = MapViewerError.searchFailed(error.localizedDescription)
                self.searchError = customErr
                throw customErr
            }
        }
        
        self.activeSearchTask = task
        return try await task.value
    }
    
    /// Executes a category-based nearby search (e.g. restaurants, gas stations, cafes).
    public func searchNearby(category: MKPointOfInterestCategory, region: MKCoordinateRegion) async throws -> [PlaceSearchResult] {
        cancelSearch()
        isSearching = true
        searchError = nil
        
        let task = Task<[PlaceSearchResult], Error> { @MainActor [weak self] in
            guard let self = self else { throw MapViewerError.operationCancelled }
            
            let request = MKLocalSearch.Request()
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
            request.region = region
            request.resultTypes = .pointOfInterest
            
            let localSearch = MKLocalSearch(request: request)
            self.activeLocalSearch = localSearch
            
            do {
                let response = try await localSearch.start()
                try Task.checkCancellation()
                
                self.isSearching = false
                let results = response.mapItems.map { PlaceSearchResult(mapItem: $0) }
                return results
            } catch is CancellationError {
                self.isSearching = false
                throw MapViewerError.operationCancelled
            } catch {
                self.isSearching = false
                let customErr = MapViewerError.searchFailed(error.localizedDescription)
                self.searchError = customErr
                throw customErr
            }
        }
        
        self.activeSearchTask = task
        return try await task.value
    }
    
    /// Cancels any active search queries.
    public func cancelSearch() {
        activeLocalSearch?.cancel()
        activeLocalSearch = nil
        activeSearchTask?.cancel()
        activeSearchTask = nil
        isSearching = false
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    public nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        Task { @MainActor in
            self.completions = results
        }
    }
    
    public nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.completions = []
        }
    }
}
